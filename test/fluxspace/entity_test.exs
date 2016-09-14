alias Fluxspace.Entity

defmodule Fluxspace.EntityTest do
  use ExUnit.Case

  test "Starting an entity gives and registers by UUID" do
    {:ok, entity_uuid, entity_pid} = Entity.start_plain("hello")

    assert entity_uuid == "hello"
    assert entity_pid == :gproc.lookup_pid({:n, :l, entity_uuid})
  end
end
