defmodule Fluxspace.Entrypoints.ClientState do
  defstruct [
    state: :not_logged_in,
    socket: nil,
    callbacks: [],
    player_pid: nil
  ]
end

defmodule Fluxspace.Entrypoints.Client do
  alias Fluxspace.Entrypoints.ClientState
  alias Fluxspace.Lib.Player

  use GenServer

  def register_callback(client_pid, pid \\ self()) do
    GenServer.call(client_pid, {:register_callback, pid})

    receive do
      {:message, message} -> message
      _ -> :error
    end
  end

  def send_message(client_pid, message) when is_pid(client_pid) do
    GenServer.cast(client_pid, {:send_message, message})
  end

  def receive_message(client_pid, message) when is_pid(client_pid) do
    GenServer.cast(client_pid, {:receive_message, message})
  end

  def enter_menu(client_pid, menu_module) when is_pid(client_pid) do
    GenServer.call(client_pid, {:enter_menu, menu_module})
  end

  def initialize_player(client_pid, player_attributes) do
    GenServer.cast(client_pid, {:initialize_player, player_attributes})
  end

  def stop(client_pid) when is_pid(client_pid) do
    GenServer.stop(client_pid)
  end

  def stop_all(client_pid) when is_pid(client_pid) do
    GenServer.cast(client_pid, :stop_all)
  end

  def start_link(socket_pid) when is_pid(socket_pid) do
    client = %ClientState{
      socket: socket_pid
    }

    GenServer.start_link(__MODULE__, client, [])
  end

  def init(client) do
    Fluxspace.Entrypoints.ClientGroup.add_client(self())

    {:ok, client}
  end

  def handle_cast({:send_message, message}, state) do
    send(state.socket, {:send_message, message})
    {:noreply, state}
  end

  def handle_cast({:receive_message, message}, state) do
    normalized_message = normalize_message(message)

    if length(state.callbacks) > 0 do
      [callback | callbacks] = state.callbacks

      send(callback, {:message, normalized_message})

      new_state = %ClientState{
        state |
        callbacks: callbacks
      }

      {:noreply, new_state}
    else
      send(state.player_pid, {:receive_message, normalized_message})
      # Fluxspace.Commands.Index.perform(normalized_message, self(), state.player_pid)

      {:noreply, state}
    end
  end

  def handle_cast(:stop_all, state) do
    send(state.socket, :close)
    {:stop, :normal, state}
  end

  def handle_cast({:initialize_player, player_attributes}, state) do
    {:ok, _player_uuid, player_pid} = Player.create(player_attributes)
    Fluxspace.Lib.Attributes.Clientable.register(player_pid, %{client_pid: self()})

    room_pid = Fluxspace.Entrypoints.ClientGroup.get_room()
    Fluxspace.Lib.Room.add_entity(room_pid, player_pid)

    new_state = %ClientState{
      state |
      state: :logged_in,
      player_pid: player_pid
    }

    {:noreply, new_state}
  end

  def handle_call({:register_callback, pid}, _from, state) do
    new_state = %ClientState{
      state |
      callbacks: [pid | state.callbacks]
    }

    {:reply, :ok, new_state}
  end

  def handle_call({:enter_menu, menu_module}, _from, state) do
    menu_module.call(self())

    {:reply, :ok, state}
  end

  def terminate(_reason, _state) do
    Fluxspace.Entrypoints.ClientGroup.remove_client(self())
  end

  def normalize_message(message) do
    String.trim(message)
  end
end
