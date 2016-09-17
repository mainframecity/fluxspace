defmodule Fluxspace.Lib.InventoryTest do
  use ExUnit.Case, async: true

  alias Fluxspace.Entity
  alias Fluxspace.Lib.Inventory

  test "Can create inventory" do
    {:ok, _uuid, entity_pid} = Entity.start
    entity_pid |> Inventory.register

    assert %Inventory{} == entity_pid |> Inventory.get
  end

  test "Can add an entity into an inventory" do
    {:ok, _uuid, entity_pid} = Entity.start
    {:ok, _, item_pid} = Entity.start
    entity_pid |> Inventory.register

    entity_pid |> Inventory.add_entity(item_pid)
    assert %Inventory{entities: [item_pid]} == entity_pid |> Inventory.get
  end

  test "Can remove an entity into an inventory" do
    {:ok, _uuid, entity_pid} = Entity.start
    {:ok, _, item_pid} = Entity.start
    entity_pid |> Inventory.register

    entity_pid |> Inventory.add_entity(item_pid)
    assert %Inventory{entities: [item_pid]} == entity_pid |> Inventory.get

    assert item_pid == entity_pid |> Inventory.remove_entity(item_pid)
    assert %Inventory{entities: []} == entity_pid |> Inventory.get
  end
end
