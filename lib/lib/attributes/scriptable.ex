alias Fluxspace.Entity

defmodule Fluxspace.Lib.Attributes.Scriptable do
  @moduledoc """
  The behaviour for an entity being Scriptable.

  Right now, it's lua scripted.
  """

  alias Fluxspace.Lib.Attributes.Scriptable
  alias Fluxspace.ScriptContext

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
      lua_code = Map.get(attributes, :lua_code, "")

      lua_state =
        ScriptContext.new()
        |> ScriptContext.add_context()
        |> ScriptContext.load_code(lua_code)

      scriptable = %Scriptable{
        lua_state: lua_state,
        lua_code: lua_code
      }

      {:ok, put_attribute(entity, scriptable)}
    end

    def handle_event({:look_from, looker_pid}, state) do
      scriptable = get_attribute(state, Scriptable)

      if ScriptContext.function_exists?(scriptable.lua_state, :handle_look_from) do
          {new_lua_state, _} =
            ScriptContext.call_function(scriptable.lua_state, :handle_look_from, [ScriptContext.encode_pid(looker_pid)])

          {:ok, put_attribute(state, %{ scriptable | lua_state: new_lua_state })}
      end
    end
  end
end
