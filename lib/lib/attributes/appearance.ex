alias Fluxspace.Entity

defmodule Fluxspace.Lib.Attributes.Appearance do
  @moduledoc """
  The behaviour for Appearance: the descriptions of entities.
  """

  alias Fluxspace.Lib.Attributes.Appearance

  defstruct [
    name: "An entity",
    short_description: "An unnamed, indescribable entity.",
    long_description: "An unnamed, indescribable entity."
  ]

  @doc """
  Registers the Appearance.Behaviour on an Entity.
  """
  def register(entity_pid, attributes \\ %{}) do
    entity_pid |> Entity.put_behaviour(Appearance.Behaviour, attributes)
  end

  @doc """
  Unregisters the Appearance.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    entity_pid |> Entity.remove_behaviour(Appearance.Behaviour)
  end

  def can_be_described?(entity_pid) do
    entity_pid |> Entity.has_behaviour?(Appearance.Behaviour)
  end

  @doc """
  Gets the name of an entity.
  """
  def get_name(entity_pid) when is_pid(entity_pid) do
    case can_be_described?(entity_pid) do
      true -> Entity.call_behaviour(entity_pid, Appearance.Behaviour, :get_name)
      false -> "This thing cannot be described!"
    end
  end

  def get_name(entity_uuid) do
    with {:ok, entity_pid} <- Entity.locate_pid(entity_uuid) do
      get_name(entity_pid)
    else
      _ -> :error
    end
  end

  @doc """
  Gets the short description of an entity.
  """
  def get_short_description(entity_pid) when is_pid(entity_pid) do
    case can_be_described?(entity_pid) do
      true -> Entity.call_behaviour(entity_pid, Appearance.Behaviour, :get_short_description)
      false -> "This thing cannot be described!"
    end
  end

  def get_short_description(entity_uuid) do
    with {:ok, entity_pid} <- Entity.locate_pid(entity_uuid) do
      get_short_description(entity_pid)
    else
      _ -> :error
    end
  end

  @doc """
  Gets the long description of an entity.
  """
  def get_long_description(entity_pid) when is_pid(entity_pid) do
    case can_be_described?(entity_pid) do
      true -> Entity.call_behaviour(entity_pid, Appearance.Behaviour, :get_long_description)
      false -> "This thing cannot be described!"
    end
  end

  def get_long_description(entity_uuid) do
    with {:ok, entity_pid} <- Entity.locate_pid(entity_uuid) do
      get_long_description(entity_pid)
    else
      _ -> :error
    end
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def init(entity, attributes) do
      {:ok, entity |> put_attribute(Map.merge(%Appearance{}, attributes))}
    end

    def get_appearance(entity), do: get_attribute(entity, Appearance)

    def handle_call(:get_name, entity) do
      appearance = get_appearance(entity)
      {:ok, appearance.name, entity}
    end

    def handle_call(:get_short_description, entity) do
      appearance = get_appearance(entity)
      {:ok, appearance.short_description, entity}
    end

    def handle_call(:get_long_description, entity) do
      appearance = get_appearance(entity)
      {:ok, appearance.long_description, entity}
    end
  end
end
