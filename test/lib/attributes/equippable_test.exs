defmodule Fluxspace.Lib.EquippableTest do
  use ExUnit.Case, async: true

  alias Fluxspace.Entity
  alias Fluxspace.Lib.Attributes.Equippable

  test "Can create entity with an appearance" do
    {:ok, _uuid, entity_pid} = Entity.start
    entity_pid |> Equippable.register()

    assert true == entity_pid |> Entity.has_behaviour?(Equippable.Behaviour)
  end

  test "Entity without appearance still get something" do
    {:ok, _uuid, entity_pid} = Entity.start
    entity_pid |> Equippable.register()

    assert :upper_body == entity_pid |> Equippable.get_slot()
  end
end
