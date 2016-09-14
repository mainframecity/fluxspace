alias Fluxspace.GenSync

defmodule Fluxspace.Entity do
  @moduledoc """
  Represents an Entity, which wraps a GenSync and provides some
  convenience functions for interacting with it.
  """

  use GenSync

  def start, do: start(UUID.uuid4())
  def start(entity_uuid), do: start(entity_uuid, %{})

  def start(entity_uuid, attributes) when is_map(attributes) do
    {:ok, ^entity_uuid, pid} = start_plain(entity_uuid, attributes)
    {:ok, entity_uuid, pid}
  end

  def start_plain(entity_uuid \\ UUID.uuid4(), attributes \\ %{}) do
    {:ok, pid} = GenSync.start_link(attributes)
    :gproc.reg_other({:n, :l, entity_uuid}, pid)
    {:ok, entity_uuid, pid}
  end

  # ---
  # Behaviour API
  # ---

  def call_behaviour(
    entity,
    behaviour,
    message
  ) when is_pid(entity) and is_atom(behaviour) do
    GenSync.call(entity, behaviour, message)
  end

  def call_behaviour(entity_uuid, behaviour, message) do
    entity_uuid |> locate_pid_and_execute(&call_behaviour(&1, behaviour, message))
  end

  def has_behaviour?(
    entity,
    behaviour
  ) when is_pid(entity) and is_atom(behaviour) do
    GenSync.has_handler?(entity, behaviour)
  end

  def has_behaviour?(entity_uuid, behaviour) do
    entity_uuid |> locate_pid_and_execute(&has_behaviour?(&1, behaviour))
  end

  def put_behaviour(
    entity,
    behaviour,
    args
  ) when is_pid(entity) and is_atom(behaviour) do
   GenSync.put_handler(entity, behaviour, args)
  end

  def put_behaviour(entity_uuid, behaviour, args) do
    entity_uuid |> locate_pid_and_execute(&put_behaviour(&1, behaviour, args))
  end

  def remove_behaviour(
    entity,
    behaviour
  ) when is_pid(entity) and is_atom(behaviour) do
    GenSync.remove_handler(entity, behaviour)
  end

  def remove_behaviour(entity_uuid, behaviour) do
    entity_uuid |> locate_pid_and_execute(&remove_behaviour(&1, behaviour))
  end

  # ---
  # Private
  # ---

  defp locate_pid_and_execute(entity_uuid, fun) do
    try do
      pid = :gproc.lookup_pid({:n, :l, entity_uuid})
      fun.(pid)
    rescue
      ArgumentError -> :error
    end
  end
end
