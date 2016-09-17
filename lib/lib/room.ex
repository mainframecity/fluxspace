alias Fluxspace.{Radio, Entity}
alias Fluxspace.Lib.Attributes.Inventory

defmodule Fluxspace.Lib.Room do
  @moduledoc """
  Behaviour for Rooms, this also implements a factory method
  called create/0 that creates a plain entity with a Room
  behaviour already registered.
  """

  alias Fluxspace.Lib.Room

  defstruct name: "A Room"

  @doc """
  Helper method for creating an plain entity that comes with a pre-installed Room.Behaviour.
  """
  def create do
    {:ok, entity_uuid, entity_pid} = Entity.start_plain()

    entity_pid |> register
    entity_pid |> Inventory.register

    {:ok, entity_uuid, entity_pid}
  end

  @doc """
  Registers a Room.Behaviour to an Entity.
  """
  def register(entity_pid) do
    Entity.put_behaviour(entity_pid, Room.Behaviour, [])
  end

  @doc """
  Unregisters a Room.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, Room.Behaviour)
  end

  @doc """
  Adds an entity to a room.
  """
  def add_entity(room_pid, entity_pid) when is_pid(room_pid) and is_pid(entity_pid) do
    with false <- Entity.has_behaviour?(entity_pid, Room.Behaviour) do
      Radio.register_observer(self, entity_pid)
      Inventory.add_entity(room_pid, entity_pid)
    else
      _ -> :error
    end
  end

  @doc """
  Removes an entity from a room.
  """
  def remove_entity(room_pid, entity_pid) when is_pid(room_pid) and is_pid(entity_pid) do
    Radio.unregister_observer(self, entity_pid)
    Inventory.remove_entity(room_pid, entity_pid)
  end

  @doc """
  Gets all entities from a room.
  """
  def get_entities(room_pid) when is_pid(room_pid) do
    Entity.call_behaviour(room_pid, Inventory.Behaviour, :get_entities)
  end

  @doc """
  Notifies all entities in a room.
  """
  def notify(room_pid, message) when is_pid(room_pid) do
    Radio.notify(room_pid, {:notify, message})
  end

  def notify(room_uuid, message) do
    notify(Entity.locate_pid!(room_uuid), message)
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, _opts) do
      {:ok, entity |> put_attribute(%Room{})}
    end
  end
end
