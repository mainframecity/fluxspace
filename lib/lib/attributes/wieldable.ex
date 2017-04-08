alias Fluxspace.Entity

defmodule Fluxspace.Lib.Attributes.Wieldable do
  @moduledoc """
  The behaviour for Wieldable, any entity that can be wielded
  as a weapon, or resembling a weapon.

  example:
    A 'rubber chicken' entity can have the wieldable attribute.
  """

  alias Fluxspace.Lib.Attributes.Wieldable

  # @slot_types [:one_handed, :two_handed]

  defstruct [
    slot: :one_handed
  ]

  @doc """
  Registers the Wieldable.Behaviour on an Entity.
  """
  def register(entity_pid, attributes \\ %{}) do
    entity_pid |> Entity.put_behaviour(Wieldable.Behaviour, attributes)
  end

  @doc """
  Unregisters the Wieldable.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    entity_pid |> Entity.remove_behaviour(Wieldable.Behaviour)
  end

  @doc """
  Gets the slot of an Equppable entity.
  """
  def get_slot(equippable_pid) do
    equippable_pid |> Entity.call_behaviour(Wieldable.Behaviour, :get_slot)
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, attributes) do
      {:ok, entity |> put_attribute(Map.merge(attributes, %Wieldable{}))}
    end

    def handle_call(:get_slot, entity) do
      equippable = entity |> get_attribute(Wieldable)

      {:ok, equippable.slot, entity}
    end
  end
end
