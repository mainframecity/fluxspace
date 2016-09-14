defmodule Fluxspace.RadioTest do
  use ExUnit.Case, async: true
  alias Fluxspace.{Entity, Radio}

  defmodule TestAttr1, do: defstruct foo: 1337, bar: "lol"
  defmodule TestAttr2, do: defstruct baz: false
  defmodule TestAttr3, do: defstruct crux: "hello"

  setup do
    {:ok, entity_uuid, _pid} = Entity.start
    entity_uuid |> Radio.register(__MODULE__)

    # Entity.put_attribute(entity_uuid, %TestAttr1{})
    # Entity.put_attribute(entity_uuid, %TestAttr2{})

    Radio.register_observer(self, __MODULE__)

    {:ok, [entity_uuid: entity_uuid]}
  end

  test "entity join" do
    {:ok, entity_uuid, _pid} = Entity.start_plain()
    Radio.register(entity_uuid, __MODULE__)
    assert_receive {
      :entity_join,
      %{
        entity_uuid: ^entity_uuid,
        attributes: %{}
      }
    }
  end
end
