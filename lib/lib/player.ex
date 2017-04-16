alias Fluxspace.Entity
alias Fluxspace.Lib.Attributes.{Appearance, Locality, Inventory}

defmodule Fluxspace.Lib.Player do
  @moduledoc """
  Entity specification for an Player.
  """

  alias Fluxspace.Lib.Player

  defstruct [
  ]


  @doc """
  Helper method for creating a plain entity with all Player attributes.
  """
  def create(attributes \\ %{}) do
    {:ok, entity_uuid, entity_pid} = Entity.start_plain()

    entity_pid |> register(attributes)
    entity_pid |> Locality.register()
    entity_pid |> Inventory.register()
    entity_pid |> Appearance.register(
      %{
        name: Map.get(attributes, :name, "Unnamed Player"),
        short_description: Map.get(attributes, :short_description, "This person does not seem to have any history or description."),
        long_description: Map.get(attributes, :long_description, "This person does not seem to have any history or description.")
      }
    )

    {:ok, entity_uuid, entity_pid}
  end

  def is_player?(entity_pid) do
    entity_pid |> Entity.has_behaviour?(Player.Behaviour)
  end

  @doc """
  Registers a Player.Behaviour to an Entity.
  """
  def register(entity_pid, attributes \\ %{}) do
    Entity.put_behaviour(entity_pid, Player.Behaviour, attributes)
  end

  @doc """
  Unregisters a Player.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, Player.Behaviour)
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, attributes) do
      {:ok, entity |> put_attribute(Map.merge(%Player{}, attributes))}
    end
  end
end
