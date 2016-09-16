alias Fluxspace.{Entity, Attribute}

defmodule Fluxspace.AttributeTest do
  use ExUnit.Case, async: true

  defmodule Life do
    defstruct health: 100

    def register(entity_pid) do
      Entity.put_behaviour(entity_pid, Life.Behaviour, %{})
    end

    def unregister(entity_pid) do
      Entity.remove_behaviour(entity_pid, Life.Behaviour)
    end

    defmodule Behaviour do
      use Entity.Behaviour

      def init(entity, _opts) do
        {:ok, put_attribute(entity, %Life{})}
      end

      def handle_call(:health, entity) do
        life = fetch_attribute!(entity, Life)

        {:ok, life.health, entity}
      end

      def handle_call({:damage, damage_points}, entity) do
        new_entity = update_attribute entity, Life, fn(life) ->
          new_health =
            case life.health - damage_points do
              health when health < 0 -> 0
              health -> health
            end

          %Life{life | health: new_health}
        end

        life = fetch_attribute!(new_entity, Life)
        {:ok, life.health, new_entity}
      end
    end
  end

  test "has? returns boolean" do
    {:ok, _entity_uuid, entity_pid} = Entity.start_plain()
    entity_pid |> Attribute.register
    entity_pid |> Life.register

    assert false == Attribute.has?(entity_pid, Attribute)
    assert true == Attribute.has?(entity_pid, Life)
  end

  test "fetch returns behaviour" do
    {:ok, _entity_uuid, entity_pid} = Entity.start_plain()
    entity_pid |> Attribute.register
    entity_pid |> Life.register

    assert {:ok, %Life{health: 100}} == entity_pid |> Attribute.fetch(Life)
  end

  test "update a behaviour" do
    {:ok, _entity_uuid, entity_pid} = Entity.start_plain()
    entity_pid |> Attribute.register
    entity_pid |> Life.register

    assert {:ok, %Life{health: 100}} == entity_pid |> Attribute.fetch(Life)
    entity_pid |> Attribute.update(Life, fn(life) -> %Life{life | health: 80} end)
    assert {:ok, %Life{health: 80}} == entity_pid |> Attribute.fetch(Life)
  end

  test "remove a behaviour" do
    {:ok, _entity_uuid, entity_pid} = Entity.start_plain()
    entity_pid |> Attribute.register
    entity_pid |> Life.register

    assert {:ok, %Life{health: 100}} == entity_pid |> Attribute.fetch(Life)
    entity_pid |> Attribute.remove(Life)
    assert :error == entity_pid |> Attribute.fetch(Life)
  end
end
