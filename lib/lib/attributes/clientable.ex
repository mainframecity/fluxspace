alias Fluxspace.Entity

defmodule Fluxspace.Lib.Attributes.Clientable do
  @moduledoc """
  The behaviour for Clientable: the ability to communicate
  to a client, and thus be able to communicate to the outside
  real-world.
  """

  require Logger

  alias Fluxspace.Lib.Attributes.Clientable

  defstruct [
    client_pid: nil,
    lua_state: nil,
    commands: %{}
  ]

  @doc """
  Registers the Clientable.Behaviour on an Entity.
  """
  def register(entity_pid, attributes \\ %{}) do
    Entity.put_behaviour(entity_pid, Clientable.Behaviour, attributes)
  end

  @doc """
  Unregisters the Clientable.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, Clientable.Behaviour)
  end

  def has_clientable?(entity_pid) do
    Entity.has_behaviour?(entity_pid, Clientable.Behaviour)
  end

  @doc """
  Sends a message through to the entity's client.
  """
  def send_message(entity_pid, message) when is_pid(entity_pid) do
    case has_clientable?(entity_pid) do
      true -> Entity.call_behaviour(entity_pid, Clientable.Behaviour, {:send_message, message})
      false -> nil
    end
  end

  defmodule Behaviour do
    use Entity.Behaviour

    alias Fluxspace.Entrypoints.Client

    def init(entity, attributes) do
      {:ok, lua_state} = load_lua_context()

      clientable = %Clientable{
        lua_state: lua_state
      }

      :fs.subscribe()

      {:ok, put_attribute(entity, Map.merge(clientable, attributes))}
    end

    def handle_call({:send_message, message}, entity) do
      send_message(entity, message)
      {:ok, :ok, entity}
    end

    def handle_event({:send_message, message}, entity) do
      send_message(entity, message)
      {:ok, entity}
    end

    def handle_event({:receive_message, ""}, entity), do: {:ok, entity}
    def handle_event({:receive_message, message}, entity) do
      [first_word | _] = String.split(message)
      rest_of_message = String.trim_leading(message, "#{first_word} ")

      clientable = get_attribute(entity, Clientable)
      command_group = Map.get(clientable.commands, first_word)

      if command_group do
        first_matching_command =
          Enum.find_value(Enum.reverse(command_group), fn({regex, _func} = value) ->
            compiled_regex = Regex.compile!(regex)

            case Regex.named_captures(compiled_regex, rest_of_message) do
              nil -> false
              captures -> {value, captures}
            end
          end)

        if first_matching_command do
          {{_, func}, captures} = first_matching_command

          # @todo(vy): String.to_atom
          function_params = [
            captures,
            Fluxspace.ScriptContext.encode_pid(self()),
            Fluxspace.ScriptContext.encode_pid(entity.parent_pid)
          ]

          appearance = get_attribute(entity, Fluxspace.Lib.Attributes.Appearance)

          modified_state =
            clientable.lua_state
            |> Lua.set_global(:name, appearance.name)

          Lua.call_function!(modified_state, String.to_atom(func), function_params)
        end
      end

      {:ok, entity}
    end

    def handle_event({:add_command, command_name, regex, function_name}, entity) do
      new_entity = update_attribute(entity, Clientable, fn(clientable) ->
        initial_command_state = [{regex, function_name}]
        new_commands = Map.update(clientable.commands, command_name, initial_command_state, fn(command_group) ->
          [{regex, function_name} | command_group]
        end)

        %Clientable{
          clientable |
          commands: new_commands
        }
      end)

      {:ok, new_entity}
    end

    def handle_event({_pid, {:fs, :file_event}, {path, _event}}, entity) do
      stringified_path = to_string(path)
      relative_path = Path.relative_to_cwd(path)
      is_command_script = String.contains?(stringified_path, "scripts/commands/")

      # Reload context
      if is_command_script do
        case load_lua_context() do
          {:error, error} ->
            Logger.error(error)
            {:ok, entity}
          {:ok, new_lua_state} ->
            IO.puts("Reloaded Lua file: #{relative_path}")
            new_entity = update_attribute(entity, Clientable, fn(clientable) ->
              %Clientable{
                clientable |
                lua_state: new_lua_state
              }
            end)
            {:ok, new_entity}
        end
      else
        {:ok, entity}
      end
    end

    def terminate(_reason, entity) do
      clientable = get_attribute(entity, Clientable)
      Client.stop_all(clientable.client_pid)
      {:ok, entity}
    end

    def send_message(entity, message) do
      clientable = get_attribute(entity, Clientable)
      Client.send_message(clientable.client_pid, message)
    end

    @spec load_lua_context() :: {:ok, Lua.State.t} | {:error, String.t}
    def load_lua_context() do
      lua_files = Fluxspace.ScriptContext.ls_r()
      initial_state = Lua.State.new() |> Fluxspace.ScriptContext.add_context()
      Enum.reduce_while(lua_files, {:ok, initial_state}, fn(lua_file, {:ok, state}) ->
        try do
          {:cont, {:ok, Lua.exec_file!(state, lua_file)}}
        rescue
          match in [MatchError] ->
            {:error, error_messages, _} = match.term
            [first_error_message | _] = error_messages
            {line_number, _, message} = first_error_message
            formatted_message = to_string(["On #{lua_file}:#{line_number}, ", message])

            {:halt, {:error, formatted_message}}
          _ ->
            {:cont, {:ok, state}}
        end
      end)
    end
  end
end
