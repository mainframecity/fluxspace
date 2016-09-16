alias Fluxspace.{Entity, Radio}

defmodule Fluxspace.EntityTest do
  use ExUnit.Case

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

  test "Starting an entity gives and registers by UUID" do
    {:ok, entity_uuid, entity_pid} = Entity.start_plain("hello")

    assert entity_uuid == "hello"
    assert entity_pid == :gproc.lookup_pid({:n, :l, entity_uuid})
  end

  test "Can add/remove handler/behaviour to Entity" do
    {:ok, _entity_uuid, entity_pid} = Entity.start_plain
    entity_pid |> Life.register
    entity_pid |> Radio.register

    assert 100 == Entity.call_behaviour(entity_pid, Life.Behaviour, :health)
    assert 80 == Entity.call_behaviour(entity_pid, Life.Behaviour, {:damage, 20})
    assert 0 == Entity.call_behaviour(entity_pid, Life.Behaviour, {:damage, 100})

    entity_pid |> Life.unregister
    assert {:error, :not_found} == Entity.call_behaviour(entity_pid, Life.Behaviour, {:damage, 100})
  end
end
