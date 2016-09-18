alias Fluxspace.{Radio, Entity}

defmodule Fluxspace.Lib.Attributes.Inventory do
  @moduledoc """
  The behaviour for Inventory, any entity that can contain
  a collection of entities and notify messages to them.

  Used for a Room, but can also be used for a bag.

  Other options may be to specify the size of the inventory,
  or only allow certain entities with a certain behaviour.

  example:
    Option to only allow entities with the 'Quiverable' attribute, for a quiver.
  """

  alias Fluxspace.Lib.Attributes.Inventory

  defstruct [
    entities: []
  ]

  @doc """
  Registers the Inventory.Behaviour on an Entity.
  """
  def register(entity_pid, attributes \\ %{}) do
    entity_pid |> Entity.put_behaviour(Inventory.Behaviour, attributes)
  end

  @doc """
  Unregisters the Inventory.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    entity_pid |> Entity.remove_behaviour(Inventory.Behaviour)
  end

  @doc """
  Adds an Entity to this Inventory.
  """
  def add_entity(inventory_pid, item_pid) do
    inventory_pid |> Radio.notify({:add_entity, item_pid})
  end

  @doc """
  Removes an Entity from this Inventory, and returns the removed Entity.
  """
  def remove_entity(inventory_pid, item_pid) do
    inventory_pid |> Entity.call_behaviour(Inventory.Behaviour, {:remove_entity, item_pid})
  end

  @doc """
  Gets the Inventory attribute in entirety.
  """
  def get(inventory_pid) do
    inventory_pid |> Entity.call_behaviour(Inventory.Behaviour, :get_inventory)
  end

  @doc """
  Gets the list of Entities in the Inventory.
  """
  def get_entities(inventory_pid) do
    inventory_pid |> Entity.call_behaviour(Inventory.Behaviour, :get_entities)
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, attributes) do
      {:ok, entity |> put_attribute(Map.merge(attributes, %Inventory{}))}
    end

    def get_entities(entity) do
      inventory = entity |> get_attribute(Inventory)
      inventory.entities
    end

    def handle_event({:add_entity, item_pid}, entity) do
      new_entity = update_attribute(entity, Inventory, fn inventory ->
        %Inventory{inventory | entities: [item_pid | inventory.entities]}
      end)

      {:ok, new_entity}
    end

    def handle_event({:notify, message}, entity) do
      entities = get_entities(entity)

      case entities do
        [] -> :ok
        [_|_] = members -> members |> Enum.map(fn pid -> send(pid, message) end)
      end

      {:ok, entity}
    end

    def handle_call({:remove_entity, item_pid}, entity) do
      new_entity = update_attribute(entity, Inventory, fn inventory ->
        %Inventory{inventory | entities: Enum.reject(inventory.entities, &(&1 == item_pid))}
      end)

      {:ok, item_pid, new_entity}
    end

    def handle_call(:get_inventory, entity) do
      {:ok, entity |> get_attribute(Inventory), entity}
    end

    def handle_call(:get_entities, entity) do
      entities = get_entities(entity)
      {:ok, entities, entity}
    end
  end
end
