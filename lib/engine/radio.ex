defmodule Fluxspace.Radio do
  @moduledoc """
  This Attribute/Behaviour, when added to an entity, allows other entities
  to be added as an observer to it. The observable entity is then able to
  notify all observers and send it any messages.

  Heavily copied/inspired from:
  https://github.com/entice/entity/blob/master/lib/entice/coordination.ex
  """

  alias Fluxspace.Entity
  alias Fluxspace.Radio

  @doc """
  Adds the Radio.Behaviour to an Entity.
  """
  def register(entity_pid) do
    Entity.put_behaviour(entity_pid, Radio.Behaviour, [])
  end

  @doc """
  Removes the Radio.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, Radio.Behaviour)
  end

  @doc """
  Registers an Entity as an observer to this Entity, allowing it to be
  notified by any broadcasted messages.
  """
  def register_observer(observer_pid, observable_pid) when is_pid(observable_pid) and is_pid(observable_pid) do
    observable_pid |> notify({:add_observer, observer_pid})
  end

  @doc """
  Unregisters an Entity as an observer of this Entity.
  """
  def unregister_observer(observer_pid, observable_pid) when is_pid(observable_pid) and is_pid(observable_pid) do
    observable_pid |> notify({:remove_observer, observer_pid})
  end

  @doc """
  Sends an event to an entity. Handled by 'handle_event' by a Behaviour
  on the entity.
  """
  def notify(entity, message) when is_pid(entity) do
    send(entity, message)
    :ok
  end

  def notify(nil, _message), do: {:error, :entity_nil}
  def notify(entity_uuid, message) do
    notify(Entity.locate_pid!(entity_uuid), message)
  end

  @doc """
  Calls a native event on entity.
  """
  def call(entity, message) when is_pid(entity) do
    GenServer.call(entity, message)
  end

  def call(nil, _message), do: {:error, :entity_nil}
  def call(entity_uuid, message) do
    call(Entity.locate_pid!(entity_uuid), message)
  end

  @doc """
  Broadcasts a message to all observers.
  """
  def notify_all(entity_pid, message) when is_pid(entity_pid) do
    notify(entity_pid, {:notify_observers, message})
  end

  def notify_all(entity_uuid, message) do
    notify_all(Entity.locate_pid!(entity_uuid), message)
  end

  defmodule Behaviour do
    use Fluxspace.Entity.Behaviour

    def init(entity, _opts) do
      :pg2.create(entity.uuid)

      {:ok, entity}
    end

    def handle_event({:add_observer, entity_pid}, entity) do
      :pg2.join(entity.uuid, entity_pid)

      {:ok, entity}
    end

    def handle_event({:remove_observer, entity_pid}, entity) do
      :pg2.leave(entity.uuid, entity_pid)

      {:ok, entity}
    end

    def handle_event({:notify_observers, message}, entity) do
      case :pg2.get_members(entity.uuid) do
        {:error, {:no_such_group, _}} -> :ok
        [] -> :ok
        [_|_] = members -> members |> Enum.map(fn pid -> send(pid, message) end)
      end

      {:ok, entity}
    end

    def handle_info({:stop, :normal}, entity) do
      case :pg2.get_members(entity.uuid) do
        {:error, {:no_such_group, _}} -> :ok
        _ -> :pg2.delete(entity.uuid)
      end

      {:ok, entity}
    end

    def terminate(_error, entity) do
      case :pg2.get_members(entity.uuid) do
        {:error, {:no_such_group, _}} -> :ok
        [] -> :ok
        members -> members |> Enum.map(fn(pid) -> send(pid, {:entity_died, self()}) end)
      end

      case :pg2.get_members(entity.uuid) do
        {:error, {:no_such_group, _}} -> :ok
        _ -> :pg2.delete(entity.uuid)
      end

      {:ok, entity}
    end

    # ---
    # Private
    # ---

    #    defp diff(old_attrs, new_attrs) do
    #      missing = old_attrs |> Map.take(Map.keys(old_attrs) -- Map.keys(new_attrs))
    #      {both, added} = Map.split(new_attrs, Map.keys(old_attrs))
    #      changed =
    #        both
    #        |> Map.keys
    #        |> Enum.filter_map(
    #            fn key -> old_attrs[key] != new_attrs[key] end,
    #            fn key -> {key, new_attrs[key]} end)
    #        |> Enum.into(%{})
    #      {added, changed, missing}
    #    end

    #    defp not_empty?({added, changed, removed}) do
    #      [added, changed, removed]
    #      |> Enum.any?(&(not Enum.empty?(&1)))
    #    end
  end
end
