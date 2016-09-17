alias Fluxspace.Entity

defmodule Fluxspace.Attribute do
  alias Fluxspace.Attribute

  @doc """
  Adds the Attribute.Behaviour to an entity, which allows us to have
  this Attribute API request information from an entity.
  """
  def register(entity_pid) do
    Entity.put_behaviour(entity_pid, Attribute.Behaviour, [])
  end

  @doc """
  Unregisters the Attribute.Behaviour from an entity, preventing it
  from being requested any information on attributes.
  """
  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, Attribute.Behaviour)
  end

  @doc """
  Checks if an entity has a certain Attribute.
  """
  def has?(entity, attribute_type) when is_atom(attribute_type) do
    Entity.call_behaviour(
      entity,
      Attribute.Behaviour,
      {:attribute_has, attribute_type}
    )
  end

  @doc """
  Fetches an Attribute from an Entity.
  """
  def fetch(entity, attribute_type) when is_atom(attribute_type) do
    Entity.call_behaviour(
      entity,
      Attribute.Behaviour,
      {:attribute_fetch, attribute_type}
    )
  end

  @doc """
  Puts an Attribute into an Entity.
  """
  def put(entity, %{__struct__: attribute_type} = attribute) do
    Entity.call_behaviour(
      entity,
      Attribute.Behaviour,
      {:attribute_put, attribute_type, attribute}
    )
  end

  @doc """
  Updates an Attribute on an Entity.
  """
  def update(entity, attribute_type, modifier)
    when is_atom(attribute_type) and is_function(modifier, 1) do
    Entity.call_behaviour(
      entity,
      Attribute.Behaviour,
      {:attribute_update, attribute_type, modifier}
    )
  end

  @doc """
  Removes an Attribute from an Entity.
  """
  def remove(entity, attribute_type) when is_atom(attribute_type) do
    Entity.call_behaviour(
      entity,
      Attribute.Behaviour,
      {:attribute_remove, attribute_type}
    )
  end

  defmodule Behaviour do
    use Entity.Behaviour

    def handle_call({:attribute_has, attribute_type}, entity) do
      {:ok, entity |> has_attribute?(attribute_type), entity}
    end

    def handle_call({:attribute_fetch, attribute_type}, entity) do
      {:ok, entity |> fetch_attribute(attribute_type), entity}
    end

    def handle_call({:attribute_put, _attribute_type, attribute}, entity) do
      new_entity = entity |> put_attribute(attribute)
      {:ok, new_entity, new_entity}
    end

    def handle_call({:attribute_update, attribute_type, modifier}, entity) do
      new_entity = entity |> update_attribute(attribute_type, modifier)
      {:ok, new_entity, new_entity}
    end

    def handle_call({:attribute_remove, attribute_type}, entity) do
      new_entity = entity |> remove_attribute(attribute_type)
      {:ok, new_entity, new_entity}
    end
  end
end
