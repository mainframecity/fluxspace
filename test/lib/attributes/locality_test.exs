defmodule Fluxspace.Lib.LocalityTest do
  use ExUnit.Case, async: true

  alias Fluxspace.Entity
  alias Fluxspace.Lib.Attributes.Locality

  @location "test_map.room.test"

  test "Can create entity with Locality" do
    {:ok, _uuid, entity_pid} = Entity.start

    entity_pid |> Locality.register()

    assert true == entity_pid |> Entity.has_behaviour?(Locality.Behaviour)
  end

  test "Can set and get location of Entity" do
    {:ok, _uuid, entity_pid} = Entity.start

    entity_pid |> Locality.register()
    entity_pid |> Locality.set_location(@location)

    assert @location == entity_pid |> Locality.get_location()
  end
end
