defmodule Fluxspace.LoaderTest do
  use ExUnit.Case

  alias Fluxspace.{Entity, EntityDefinition}
  alias Fluxspace.Loader

  alias Fluxspace.Lib.Attributes.Appearance

  @json_definition %{
    "attributes" => %{
      "Appearance" => %{
          "name" => "Test Name",
          "short_description" => "Short Description",
          "long_description" => "Long Description"
      }
    }
  }

  test "Can load JSON definition" do
    assert %EntityDefinition{
      filepath: "test.fluxdef",
      attributes: @json_definition["attributes"]
    } == Loader.load_definition("test.fluxdef", @json_definition)
  end

  test "Can load JSON definition from file" do
    assert %EntityDefinition{
      filepath: "./test/fixtures/test.fluxdef",
      attributes: @json_definition["attributes"]
    } == Loader.load_definition("./test/fixtures/test.fluxdef")
  end

  test "Can create entity from JSON definition" do
    definition = Loader.load_definition("test.fluxdef", @json_definition)
    {:ok, _, entity_pid} = definition |> EntityDefinition.to_entity()

    assert true == entity_pid |> Entity.has_behaviour?(Appearance.Behaviour)
    assert @json_definition["attributes"]["Appearance"]["name"] == Appearance.get_name(entity_pid)
  end
end
