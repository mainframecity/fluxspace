alias Fluxspace.Entity
alias Fluxspace.Lib.Attributes.{Appearance, Locality, Inventory}

defmodule Fluxspace.Lib.NPC do
  @moduledoc """
  Entity specification for an NPC.
  """

  alias Fluxspace.Lib.NPC

  defstruct [
  ]


  @doc """
  Helper method for creating a plain entity with all NPC attributes.
  """
  def create(attributes \\ %{}) do
    {:ok, entity_uuid, entity_pid} = Entity.start_plain()

    entity_pid |> register(attributes)
    entity_pid |> Locality.register()
    entity_pid |> Inventory.register()
    entity_pid |> Appearance.register(
      %{
        name: "Unnamed NPC",
        short_description: "This person does not seem to have any history or description.",
        long_description: "This person does not seem to have any history or description."
      }
    )

    {:ok, entity_uuid, entity_pid}
  end

  @doc """
  Registers a NPC.Behaviour to an Entity.
  """
  def register(entity_pid, attributes \\ %{}) do
    Entity.put_behaviour(entity_pid, NPC.Behaviour, attributes)
  end

  @doc """
  Unregisters a NPC.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, NPC.Behaviour)
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, attributes) do
      {:ok, entity |> put_attribute(Map.merge(%NPC{}, attributes))}
    end
  end
end
