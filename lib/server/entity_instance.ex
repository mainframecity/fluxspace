defmodule Fluxspace.EntityInstance do
  alias Fluxspace.EntityInstance
  alias Fluxspace.Entity

  defstruct [
    uuid: "",
    attributes: %{}
  ]

  def from_entity(entity_pid) do
    entity = Entity.get_state(entity_pid)

    %EntityInstance{
      uuid: entity.state.uuid,
      attributes: entity.state.attributes
    } |> Poison.encode!
  end
end
