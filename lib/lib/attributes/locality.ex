alias Fluxspace.{Entity, Radio}

defmodule Fluxspace.Lib.Attributes.Locality do
  @moduledoc """
  The behaviour for Locality: the location of the entity
  """

  alias Fluxspace.Lib.Attributes.Locality

  defstruct [
    x: 0,
    y: 0
  ]

  @doc """
  Registers the Locality.Behaviour on an Entity.
  """
  def register(entity_pid, attributes \\ %{}) do
    entity_pid |> Entity.put_behaviour(Locality.Behaviour, attributes)
  end

  @doc """
  Unregisters the Locality.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    entity_pid |> Entity.remove_behaviour(Locality.Behaviour)
  end

  def has_location?(entity_pid) do
    entity_pid |> Entity.has_behaviour?(Locality.Behaviour)
  end

  @doc """
  Gets the location of an entity.
  """
  def get_location(entity_pid) when is_pid(entity_pid) do
    case has_location?(entity_pid) do
      true -> Entity.call_behaviour(entity_pid, Locality.Behaviour, :get_location)
      false -> "This thing cannot have a location!"
    end
  end

  def get_location(entity_uuid) do
    with {:ok, entity_pid} <- Entity.locate_pid(entity_uuid) do
      get_location(entity_pid)
    else
      _ -> :error
    end
  end

  @doc """
  Sets the location of an entity.
  """
  def set_location(entity_pid, location) when is_pid(entity_pid) do
    case has_location?(entity_pid) do
      true -> Radio.notify(entity_pid, {:set_location, location})
      false -> "This thing cannot have a location!"
    end
  end

  def set_location(entity_uuid, location) do
    with {:ok, entity_pid} <- Entity.locate_pid(entity_uuid) do
      set_location(entity_pid, location)
    else
      _ -> :error
    end
  end


  @doc """
  Given an X or Y, modifies that value.
  """
  def modify_location(entity_pid, :x, :inc) do
    Radio.notify(entity_pid, {:modify_location, :x, :inc})
  end

  def modify_location(entity_pid, :x, :dec) do
    Radio.notify(entity_pid, {:modify_location, :x, :dec})
  end

  def modify_location(entity_pid, :y, :inc) do
    Radio.notify(entity_pid, {:modify_location, :y, :inc})
  end

  def modify_location(entity_pid, :y, :dec) do
    Radio.notify(entity_pid, {:modify_location, :y, :dec})
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, attributes) do
      {:ok, entity |> put_attribute(Map.merge(%Locality{}, attributes))}
    end

    def get_locality(entity), do: get_attribute(entity, Locality)

    def handle_call(:get_location, entity) do
      locality = get_locality(entity)

      {:ok, {locality.x, locality.y}, entity}
    end

    def handle_event({:set_location, {x, y}}, entity) do
      new_entity = update_attribute(entity, Locality, fn locality ->
        %Locality{locality | x: x, y: y}
      end)

      {:ok, new_entity}
    end

    def handle_event({:modify_location, component, action}, entity) do
      new_entity = update_attribute(entity, Locality, fn locality ->
        case {component, action} do
          {:x, :inc} -> %Locality{locality | x: locality.x + 1}
          {:x, :dec} -> %Locality{locality | x: locality.x - 1}
          {:y, :inc} -> %Locality{locality | y: locality.y + 1}
          {:y, :dec} -> %Locality{locality | y: locality.y - 1}
        end
      end)

      {:ok, new_entity}
    end
  end
end
