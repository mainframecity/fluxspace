alias Fluxspace.{Entity, Radio}

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
      {:ok, put_attribute(entity, Map.merge(%Scriptable{}, attributes))}
    end
  end
end
