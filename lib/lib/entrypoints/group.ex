defmodule Fluxspace.Entrypoints.ClientGroup do
  @moduledoc """
  Temporary module to hold all the Clients that exist in the game.
  """

  use GenServer
  alias Fluxspace.Entrypoints.Client

  defstruct [
    clients: [],
    room_pid: nil
  ]

  def start_link() do
    GenServer.start_link(__MODULE__, %__MODULE__{}, [name: __MODULE__])
  end

  def add_client(client) do
    GenServer.call(__MODULE__, {:add_client, client})
  end

  def remove_client(client) do
    GenServer.call(__MODULE__, {:remove_client, client})
  end

  def send_message(client, message) do
    GenServer.call(__MODULE__, {:send_message, client, message})
  end

  def broadcast_message(sender_client, message) do
    GenServer.call(__MODULE__, {:broadcast_message, sender_client, message})
  end

  def get_room() do
    GenServer.call(__MODULE__, :get_room)
  end

  def init(state) do
    {:ok, _room_uuid, room_pid} = Fluxspace.Lib.Room.create()
    {:ok, _, terminal} = Fluxspace.Entity.start_plain()

    Fluxspace.Lib.Attributes.Appearance.register(terminal,
      %{
        name: "terminal",
        short_description: "It connects you to the outside world.",
        long_description: "A dented yellow-ish terminal box with a glass screen that bulges out from the front-facing side. A keyboard is soldered onto the front."
      }
    )

    Fluxspace.Lib.Room.add_entity(room_pid, terminal)

    new_state = %__MODULE__{
      state |
      room_pid: room_pid
    }

    {:ok, new_state}
  end

  def handle_call({:add_client, client}, _from, state) do
    new_state = %__MODULE__{
      state |
      clients: [client | state.clients]
    }

    {:reply, :ok, new_state}
  end

  def handle_call({:remove_client, client}, _from, state) do
    new_state = %__MODULE__{
      state |
      clients: Enum.reject(state.clients, fn(compared_client) ->
        compared_client == client
      end)
    }

    {:reply, :ok, new_state}
  end

  def handle_call({:broadcast_message, sender_client, message}, _from, state) do
    Enum.each(state.clients, fn(client) ->
      if client != sender_client do
        Client.send_message(client, message)
      end
    end)

    {:reply, :ok, state}
  end

  def handle_call(:get_room, _from, state) do
    {:reply, state.room_pid, state}
  end
end
