alias Fluxspace.GenSync

defmodule Fluxspace.Entity do
  @moduledoc """
  Represents an Entity, which wraps a GenSync and provides some
  convenience functions for interacting with it.
  """

  defstruct uuid: "", attributes: %{}

  use GenSync

  alias Fluxspace.{Entity, Radio}

  def start, do: start(UUID.uuid4())
  def start(entity_uuid), do: start(entity_uuid, %{})

  def start(entity_uuid, attributes) when is_map(attributes) do
    {:ok, ^entity_uuid, pid} = start_plain(entity_uuid, attributes)
    {:ok, entity_uuid, pid}
  end

  def start_plain(entity_uuid \\ UUID.uuid4(), attributes \\ %{}) do
    {:ok, pid} = GenSync.start_link(%Entity{uuid: entity_uuid, attributes: attributes})

    :gproc.reg_other({:n, :l, entity_uuid}, pid)
    pid |> Radio.register

    {:ok, entity_uuid, pid}
  end

  def locate_pid(entity_uuid) do
    try do
      pid = :gproc.lookup_pid({:n, :l, entity_uuid})
      {:ok, pid}
    rescue
      ArgumentError -> :error
    end
  end

  def locate_pid!(entity_uuid) do
    try do
      :gproc.lookup_pid({:n, :l, entity_uuid})
    rescue
      ArgumentError -> raise "Entity not found: #{entity_uuid}"
    end
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

  defmodule Behaviour do
    defmacro __using__(_) do
      quote do
        use GenSync
        alias Fluxspace.Entity

        def create(_args), do: Entity.start_plain()

        def init(entity, _args), do: {:ok, entity}

        def has_attribute?(%Entity{attributes: attrs}, attribute_type) when is_atom(attribute_type),
        do: Map.has_key?(attrs, attribute_type)

        def fetch_attribute(%Entity{attributes: attrs}, attribute_type) when is_atom(attribute_type),
        do: Map.fetch(attrs, attribute_type)

        def fetch_attribute!(%Entity{attributes: attrs}, attribute_type) when is_atom(attribute_type),
        do: Map.fetch!(attrs, attribute_type)

        def get_attribute(%Entity{attributes: attrs}, attribute_type) when is_atom(attribute_type),
        do: Map.get(attrs, attribute_type)

        def take_attributes(%Entity{attributes: attrs}, attribute_types) when is_list(attribute_types),
        do: Map.take(attrs, attribute_types)

        def put_attribute(%Entity{attributes: attrs} = entity, %{__struct__: attribute_type} = attribute),
        do: %Entity{entity | attributes: Map.put(attrs, attribute_type, attribute)}

        def update_attribute(%Entity{attributes: attrs} = entity, attribute_type, modifier)
        when is_atom(attribute_type) and is_function(modifier, 1) do
          case Map.has_key?(attrs, attribute_type) do
            true -> %Entity{entity | attributes: Map.update!(attrs, attribute_type, modifier)}
            false -> entity
          end
        end

        def remove_attribute(%Entity{attributes: attrs} = entity, attribute_type) when is_atom(attribute_type),
        do: %Entity{entity | attributes: Map.delete(attrs, attribute_type)}

        def attribute_transaction(%Entity{attributes: attrs} = entity, modifier) when is_function(modifier, 1),
        do: %Entity{entity | attributes: modifier.(attrs)}

        defoverridable [create: 1, init: 2]
      end
    end
  end
end
