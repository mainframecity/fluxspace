alias Fluxspace.Entity

defmodule Fluxspace.Lib.Attributes.Clientable do
  @moduledoc """
  The behaviour for Clientable: the ability to communicate
  to a client, and thus be able to communicate to the outside
  real-world.
  """

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
      lua_files = Fluxspace.ScriptContext.ls_r()
      initial_state = Lua.State.new() |> Fluxspace.ScriptContext.add_context()
      lua_state = Enum.reduce(lua_files, initial_state, fn(lua_file, state) ->
        Lua.exec_file!(state, lua_file)
      end)

      clientable = %Clientable{
        lua_state: lua_state
      }

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

    def send_message(entity, message) do
      clientable = get_attribute(entity, Clientable)
      Client.send_message(clientable.client_pid, message)
    end
  end
end
