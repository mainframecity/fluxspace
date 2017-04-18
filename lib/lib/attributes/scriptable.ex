alias Fluxspace.Entity

defmodule Fluxspace.Lib.Attributes.Scriptable do
  @moduledoc """
  The behaviour for an entity being Scriptable.

  Right now, it's lua scripted.
  """

  alias Fluxspace.Lib.Attributes.Scriptable

  defstruct [
    lua_state: nil,
    lua_code: ""
  ]

  def register(entity_pid, attributes \\ %{}) do
    Entity.put_behaviour(entity_pid, Scriptable.Behaviour, attributes)
  end

  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, Scriptable.Behaviour)
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, attributes) do
      lua_state =
        Lua.State.new()
        |> Lua.set_global(:self, encode_pid(self()))
        |> Lua.set_global(:send_message, fn(state, [pid, message]) ->
          send(decode_pid(pid), {:send_message, [message, "\r\n"]})
          {state, [true]}
        end)
        |> Lua.exec!(Map.get(attributes, :lua_code, ""))

      scriptable = %Scriptable{
        lua_state: lua_state,
        lua_code: Map.get(attributes, :lua_code, "")
      }

      {:ok, put_attribute(entity, scriptable)}
    end

    def handle_event({:look_from, looker_pid}, state) do
      scriptable = get_attribute(state, Scriptable)

      case Lua.get_global(scriptable.lua_state, :handle_look_from) do
        {_, nil} ->
          {:ok, state}
        {_, _function} ->
          {new_lua_state, _} =
            Lua.call_function!(scriptable.lua_state, :handle_look_from, [encode_pid(looker_pid)])

          {:ok, put_attribute(state, %{ scriptable | lua_state: new_lua_state })}
      end
    end

    def encode_pid(pid) do
      :erlang.pid_to_list(pid)
      |> :erlang.list_to_binary()
    end

    def decode_pid(pid) do
      :erlang.binary_to_list(pid)
      |> :erlang.list_to_pid()
    end
  end
end
