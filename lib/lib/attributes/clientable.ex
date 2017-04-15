alias Fluxspace.Entity

defmodule Fluxspace.Lib.Attributes.Clientable do
  @moduledoc """
  The behaviour for Clientable: the ability to communicate
  to a client, and thus be able to communicate to the outside
  real-world.
  """

  alias Fluxspace.Lib.Attributes.Clientable

  defstruct [
    client_pid: nil
  ]

  @doc """
  Registers the Clientable.Behaviour on an Entity.
  """
  def register(entity_pid, attributes \\ %{}) do
    Entity.put_behaviour(entity_pid, Clientable.Behaviour, attributes)
  end

  @doc """
  Unregisters the Clientable.Behaviour from an Entity.
  """
  def unregister(entity_pid) do
    Entity.remove_behaviour(entity_pid, Clientable.Behaviour)
  end

  def has_clientable?(entity_pid) do
    Entity.has_behaviour?(entity_pid, Clientable.Behaviour)
  end

  @doc """
  Sends a message through to the entity's client.
  """
  def send_message(entity_pid, message) when is_pid(entity_pid) do
    case has_clientable?(entity_pid) do
      true -> Entity.call_behaviour(entity_pid, Clientable.Behaviour, {:send_message, message})
      false -> nil
    end
  end

  defmodule Behaviour do
    use Entity.Behaviour

    alias Fluxspace.Entrypoints.Client

    def init(entity, attributes) do
      {:ok, put_attribute(entity, Map.merge(%Clientable{}, attributes))}
    end

    def handle_call({:send_message, message}, entity) do
      send_message(entity, message)
      {:ok, entity}
    end

    def handle_event({:send_message, message}, entity) do
      send_message(entity, message)
      {:ok, entity}
    end

    def send_message(entity, message) do
      clientable = get_attribute(entity, Clientable)
      Client.send_message(clientable.client_pid, message)
    end
  end
end
