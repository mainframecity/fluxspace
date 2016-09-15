alias Fluxspace.Entity

defmodule Fluxspace.Attribute do
  alias Fluxspace.Attribute

  def register(entity_pid) do
    Entity.put_behaviour(entity_pid, Attribute.Behaviour, [])
  end

  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, Attribute.Behaviour)
  end

  def has?(entity, attribute_type) when is_atom(attribute_type) do
    Entity.call_behaviour(
      entity,
      Attribute.Behaviour,
      {:attribute_has, attribute_type}
    )
  end

  def fetch(entity, attribute_type) when is_atom(attribute_type) do
    Entity.call_behaviour(
      entity,
      Attribute.Behaviour,
      {:attribute_fetch, attribute_type}
    )
  end

  def put(entity, %{__struct__: attribute_type} = attribute) do
    Entity.call_behaviour(
      entity,
      Attribute.Behaviour,
      {:attribute_put, attribute_type, attribute}
    )
  end

  def update(entity, attribute_type, modifier)
    when is_atom(attribute_type) and is_function(modifier, 1) do
    Entity.call_behaviour(
      entity,
      Attribute.Behaviour,
      {:attribute_update, attribute_type, modifier}
    )
  end

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
