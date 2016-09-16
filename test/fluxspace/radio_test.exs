defmodule Fluxspace.RadioTest do
  use ExUnit.Case, async: true
  alias Fluxspace.{Entity, Radio}

  defmodule TestAttr1, do: defstruct foo: 1337, bar: "lol"
  defmodule TestAttr2, do: defstruct baz: false
  defmodule TestAttr3, do: defstruct crux: "hello"

  setup do
    {:ok, entity_uuid, _pid} = Entity.start
    entity_uuid |> Radio.register

    {:ok, [entity_uuid: entity_uuid]}
  end

  test "Can listen on another entity", %{entity_uuid: entity_uuid} do
    Radio.register_observer(self, Entity.locate_pid!(entity_uuid))
    entity_uuid |> Radio.notify_all(:foo)

    assert_receive :foo
  end
end
