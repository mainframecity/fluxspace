defmodule Fluxspace.Entrypoints.ClientState do
  defstruct [
    socket: nil,
    callbacks: []
  ]
end

defmodule Fluxspace.Entrypoints.Client do
  alias Fluxspace.Entrypoints.ClientState

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
      Fluxspace.Commands.Index.do_command(normalized_message, self())

      {:noreply, state}
    end
  end

  def handle_cast(:stop_all, state) do
    send(state.socket, :close)
    {:stop, :normal, state}
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
