defmodule Fluxspace.Lib.WieldableTest do
  use ExUnit.Case, async: true

  alias Fluxspace.Entity
  alias Fluxspace.Lib.Attributes.Wieldable

  test "Can create entity with an appearance" do
    {:ok, _uuid, entity_pid} = Entity.start
    entity_pid |> Wieldable.register()

    assert true == entity_pid |> Entity.has_behaviour?(Wieldable.Behaviour)
  end

  test "Entity without appearance still get something" do
    {:ok, _uuid, entity_pid} = Entity.start
    entity_pid |> Wieldable.register()

    assert :one_handed == entity_pid |> Wieldable.get_slot()
  end
end
