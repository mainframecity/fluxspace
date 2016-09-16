defmodule Fluxspace.Lib.RoomTest do
  use ExUnit.Case, async: true

  alias Fluxspace.{Entity, Radio}
  alias Fluxspace.Lib.Room

  defmodule Test do
    defstruct [:test_pid]

    def register(entity_pid, opts \\ %{}) do
      Entity.put_behaviour(entity_pid, Test.Behaviour, opts)
    end

    def unregister(entity_pid) do
      Entity.remove_behaviour(entity_pid, Test.Behaviour)
    end

    defmodule Behaviour do
      use Entity.Behaviour

      def init(entity, opts) do
        {:ok, entity |> put_attribute(%Test{test_pid: opts.test_pid})}
      end

      def handle_event(:from_room, entity) do
        test = entity |> get_attribute(Test)
        send(test.test_pid, :got)
        {:ok, entity}
      end

      def handle_event(:to_room, entity) do
        Radio.notify_all(self(), :from_entity)
        {:ok, entity}
      end
    end
  end

  setup do
    {:ok, room_uuid, room_pid} = Room.create([])
    {:ok, [room_uuid: room_uuid, room_pid: room_pid]}
  end

  test "Can create a room pid", %{room_uuid: room_uuid, room_pid: room_pid} do
    assert Entity.locate_pid!(room_uuid) == room_pid
  end

  test "Can add/remove an entity to a room", %{room_pid: room_pid} do
    {:ok, _entity_uuid, entity_pid} = Entity.start_plain()

    assert :ok == Room.add_entity(room_pid, entity_pid)
    assert [entity_pid] == Room.get_entities(room_pid)
    assert :ok == Room.remove_entity(room_pid, entity_pid)
    assert [] == Room.get_entities(room_pid)
  end

  test "Can fire events to entities", %{room_uuid: room_uuid, room_pid: room_pid} do
    {:ok, _entity_uuid, entity_pid} = Entity.start_plain()

    entity_pid |> Test.register(%{test_pid: self()})

    assert :ok == Room.add_entity(room_pid, entity_pid)

    Room.notify(room_uuid, :from_room)

    assert_receive :got
  end

  test "Cannot add a room to a room", %{room_pid: room_pid} do
    {:ok, _, room2_pid} = Room.create([])
    assert :error == Room.add_entity(room_pid, room2_pid)
  end
end
