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

  defmodule Behaviour do
    use Entity.Behaviour

    def handle_call({:attribute_has, attribute_type}, entity) do
      {:ok, entity |> has_attribute?(attribute_type), entity}
    end
  end
end
