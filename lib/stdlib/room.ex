alias Fluxspace.{Radio, Entity}

defmodule Fluxspace.Lib.Room do
  use Entity.Behaviour

  alias Fluxspace.Lib.Room

  defstruct name: "A Room", entities: []

  def create(args) do
    {:ok, entity_uuid, entity_pid} = super(args)

    entity_pid |> register

    {:ok, entity_uuid, entity_pid}
  end

  def register(entity_pid) do
    Entity.put_behaviour(entity_pid, Room.Behaviour, [])
  end

  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, Room.Behaviour)
  end

  def add_entity(room_pid, entity_pid) when is_pid(room_pid) and is_pid(entity_pid) do
    with false <- Entity.has_behaviour?(entity_pid, Room.Behaviour) do
      Radio.notify(room_pid, {:add_entity, entity_pid})
    else
      _ -> :error
    end
  end

  def remove_entity(room_pid, entity_pid) when is_pid(room_pid) and is_pid(entity_pid) do
    Radio.notify(room_pid, {:remove_entity, entity_pid})
  end

  def get_entities(room_pid) when is_pid(room_pid) do
    Entity.call_behaviour(room_pid, Room.Behaviour, :get_entities)
  end

  def notify(room_pid, message) when is_pid(room_pid) do
    Radio.notify(room_pid, {:notify, message})
  end

  def notify(room_uuid, message) do
    notify(Entity.locate_pid!(room_uuid), message)
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, _opts) do
      {:ok, entity |> put_attribute(%Room{})}
    end

    def handle_event({:add_entity, entity_pid}, entity) do
      Radio.register_observer(self, entity_pid)
      {:ok, entity |> update_attribute(Room, fn(room) -> %Room{room | entities: [entity_pid | room.entities]} end)}
    end

    def handle_event({:remove_entity, entity_pid}, entity) do
      Radio.unregister_observer(self, entity_pid)
      {:ok, entity |> update_attribute(Room, fn(room) -> %Room{room | entities: Enum.reject(room.entities, &(&1 == entity_pid))} end)}
    end

    def handle_event({:notify, message}, entity) do
      entities =
        with attribute = entity |> get_attribute(Room) do
          attribute.entities
        end

      case entities do
        [] -> :ok
        [_|_] = members -> members |> Enum.map(fn pid -> send(pid, message) end)
      end

      {:ok, entity}
    end

    def handle_call(:get_entities, entity) do
      entities =
        with attribute = entity |> get_attribute(Room) do
          attribute.entities
        end

      {:ok, entities, entity}
    end
  end
end
