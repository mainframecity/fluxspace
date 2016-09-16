defmodule Fluxspace.Radio do
  @moduledoc """
  Observes entities and propagates their state changes to different channels.

  Heavily copied/inspired from:
  https://github.com/entice/entity/blob/master/lib/entice/coordination.ex
  """

  defstruct channel: nil

  alias Fluxspace.Entity

  def register(
    entity_uuid,
    channel
  ) when not is_pid(entity_uuid) do
    register(Entity.locate_pid!(entity_uuid), channel)
  end

  def register(entity, channel) do
    :pg2.create(channel)
    :pg2.join(channel, entity)
    Entity.put_behaviour(entity, Fluxspace.Radio.Behaviour, {channel})
  end

  def register_observer(pid, channel) when is_pid(pid) do
    :pg2.create(channel)
    :pg2.join(channel, pid)
    notify_observe(channel, pid)
  end

  def unregister_observer(pid, channel) when is_pid(pid) do
    :pg2.leave(channel, pid)
  end

  def stop_channel(channel) do
    case :pg2.get_members(channel) do
      {:error, {:no_such_group, ^channel}} -> :ok
      [] -> :pg2.delete(channel)
      [_|_] = members ->
        members |> Enum.map(fn pid -> send(pid, {:radio_stop_channel, channel}) end)
        :pg2.delete(channel)
    end
  end

  def notify(entity, message) when is_pid(entity) do
    send(entity, message)
    :ok
  end

  def notify(nil, _message), do: {:error, :entity_nil}
  def notify(entity_uuid, message) do
    notify(Entity.locate_pid!(entity_uuid), message)
  end

  def notify_locally(entity, message) do
    notify(entity, {:radio_notify_locally, message})
  end

  def notify_all(channel, message) do
    case :pg2.get_members(channel) do
      {:error, {:no_such_group, ^channel}} -> :error
      [] -> :ok
      [_|_] = members ->
        members |> Enum.map(fn pid -> send(pid, message) end)
    end
  end

  def get_all(channel), do: :pg2.get_members(channel)

  # ---
  # Internal API
  # ---

  def notify_join(
    channel,
    entity_uuid,
    %{} = attributes
  ) when not is_pid(entity_uuid) do
    notify_all(
      channel,
      {:entity_join, %{entity_uuid: entity_uuid, attributes: attributes}}
    )
  end

  def notify_change(
    channel,
    entity_uuid,
    {%{} = added, %{} = changed, %{} = removed}
  ) when not is_pid(entity_uuid) do
    notify_all(channel, {:entity_change, %{entity_uuid: entity_uuid, added: added, changed: changed, removed: removed}})
  end

  def notify_leave(
    channel,
    entity_uuid,
    %{} = attributes
  ) when not is_pid(entity_uuid) do
    notify_all(channel, {:entity_leave, %{entity_uuid: entity_uuid, attributes: attributes}})
  end

  def notify_observe(channel, pid) when is_pid(pid) do
    notify_all(channel, {:observer_join, %{observer: pid}})
  end

  defmodule Behaviour do
    use Fluxspace.Entity.Behaviour
    alias Fluxspace.Entity
    alias Fluxspace.Radio

    def init(%Entity{attributes: attribs} = entity, {channel}) do
      Radio.notify_join(channel, entity.uuid, attribs)
      {:ok, entity |> put_attribute(%Radio{channel: channel})}
    end

    def handle_event(
      {:radio_stop_channel, channel},
      %Entity{attributes: %{Radio => %Radio{channel: channel}}} = entity
    ) do
      {:stop, :stop_channel, entity}
    end

    def handle_event(
      {:radio_notify_locally, message},
      %Entity{attributes: %{Radio => %Radio{channel: channel}}} = entity
    ) do
      Radio.notify_all(channel, message)
      {:ok, entity}
    end

    def handle_event(
      {:entity_join, %{entity_id: sender_entity, attributes: _attrs}},
      %Entity{attributes: attribs} = entity
    ) do
      Radio.notify(
        sender_entity,
        {:entity_join, %{entity_uuid: entity.uuid, attributes: attribs}}
      )
      {:ok, entity}
    end

    def handle_event(
      {:observer_join, %{observer: sender_pid}},
      %Entity{attributes: attribs} = entity
    ) do
      send(
        sender_pid,
        {:entity_join, %{entity_uuid: entity.uuid, attributes: attribs}}
      )
      {:ok, entity}
    end

    def handle_change(
        %Entity{attributes: old_attributes},
        %Entity{attributes: %{Radio => %Radio{channel: channel}} = new_attributes} = entity) do
      change_set = diff(old_attributes, new_attributes)
      if not_empty?(change_set), do: Radio.notify_change(channel, entity.uuid, change_set)
      :ok
    end

    def terminate(:stop_channel, entity), do: {:ok, entity}

    def terminate(_reason, %Entity{attributes: %{Radio => %Radio{channel: channel}} = attribs} = entity) do
      Radio.notify_leave(channel, entity.uuid, attribs)
      {:ok, entity}
    end

    # ---
    # Private
    # ---

    defp diff(old_attrs, new_attrs) do
      missing = old_attrs |> Map.take(Map.keys(old_attrs) -- Map.keys(new_attrs))
      {both, added} = Map.split(new_attrs, Map.keys(old_attrs))
      changed =
        both
        |> Map.keys
        |> Enum.filter_map(
            fn key -> old_attrs[key] != new_attrs[key] end,
            fn key -> {key, new_attrs[key]} end)
        |> Enum.into(%{})
      {added, changed, missing}
    end

    defp not_empty?({added, changed, removed}) do
      [added, changed, removed]
      |> Enum.any?(&(not Enum.empty?(&1)))
    end
  end
end
