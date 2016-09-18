defmodule Fluxspace.Lib.NPCTest do
  use ExUnit.Case, async: true

  alias Fluxspace.Lib.Attributes.Appearance
  alias Fluxspace.Lib.NPC

  @name "Unnamed NPC"
  @short_description "This person does not seem to have any history or description."
  @long_description "This person does not seem to have any history or description."


  test "Can create NPC and get appearance" do
    {:ok, _uuid, entity_pid} = NPC.create

    assert @name == Appearance.get_name(entity_pid)
    assert @short_description == Appearance.get_short_description(entity_pid)
    assert @long_description == Appearance.get_long_description(entity_pid)
  end

end
