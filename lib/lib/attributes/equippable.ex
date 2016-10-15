alias Fluxspace.Entity

defmodule Fluxspace.Lib.Attributes.Equippable do
  @moduledoc """
  The behaviour for Equippable, any entity that can equipped
  by another Entity.

  example:
   A 'Pants' entity are equippable as armor.
  """

  alias Fluxspace.Lib.Attributes.Equippable

  @slot_types [:head, :feet, :lower_body, :upper_body]

  defstruct [
    slot: :upper_body
  ]

  @doc """
  Registers the Equippable.Behaviour on an Entity.
  """
  def register(entity_pid, attributes \\ %{}) do
    entity_pid |> Entity.put_behaviour(Equippable.Behaviour, attributes)
  end

  @doc """
  Unregisters the Equippable.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    entity_pid |> Entity.remove_behaviour(Equippable.Behaviour)
  end

  @doc """
  Gets the slot of an Equppable entity.
  """
  def get_slot(equippable_pid) do
    equippable_pid |> Entity.call_behaviour(Equippable.Behaviour, :get_slot)
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, attributes) do
      {:ok, entity |> put_attribute(Map.merge(attributes, %Equippable{}))}
    end

    def handle_call(:get_slot, entity) do
      equippable = entity |> get_attribute(Equippable)

      {:ok, equippable.slot, entity}
    end
  end
end
