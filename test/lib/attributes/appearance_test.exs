defmodule Fluxspace.Lib.AppearanceTest do
  use ExUnit.Case, async: true

  alias Fluxspace.Entity
  alias Fluxspace.Lib.Attributes.Appearance

  @name "Test Entity"
  @short_description "A test entity"
  @long_description "A test entity created just for this test"

  @unnamed "This thing cannot be described!"

  test "Can create entity with an appearance" do
    {:ok, _uuid, entity_pid} = Entity.start

    entity_pid |> Appearance.register(%{name: @name, short_description: @short_description, long_description: @long_description})

    assert true == entity_pid |> Entity.has_behaviour?(Appearance.Behaviour)
    assert @name == Appearance.get_name(entity_pid)
    assert @short_description == Appearance.get_short_description(entity_pid)
    assert @long_description == Appearance.get_long_description(entity_pid)
  end

  test "Entity without appearance still get something" do
    {:ok, _uuid, entity_pid} = Entity.start

    assert false == entity_pid |> Entity.has_behaviour?(Appearance.Behaviour)
    assert nil == Appearance.get_name(entity_pid) # Except for names, because they are used for identifying.
    assert @unnamed == Appearance.get_short_description(entity_pid)
    assert @unnamed == Appearance.get_long_description(entity_pid)
  end
end
