defmodule Fluxspace.Entrypoints.Client do
  alias Fluxspace.Lib.Player

  use GenServer

  defstruct [
    player_uuid: "",
    player_pid: nil,
    entrypoint_module: Fluxspace.Entrypoints.Dummy,
    entrypoint_pid: nil,
    client_pid: nil,
    socket: nil,
    halted: false,
    initialized: false,
    unique_ref: nil,
    callbacks: []
  ]

  def register_callback(client, pid \\ self()) do
    GenServer.call(client.client_pid, {:register_callback, pid})

    receive do
      {:message, message} -> message
      _ -> :error
    end
  end

  def send_message(%__MODULE__{} = client, message) do
    client.entrypoint_module.send_message(client, message)
  end

  def send_message(client_pid, message) when is_pid(client_pid) do
    GenServer.call(client_pid, {:send_message, message})
  end

  def enter_menu(client_pid, menu_module) when is_pid(client_pid) do
    GenServer.call(client_pid, {:enter_menu, menu_module})
  end

  def stop(client_pid) when is_pid(client_pid) do
    GenServer.stop(client_pid)
  end

  def close(%__MODULE__{} = client) do
    client.entrypoint_module.close(client)
    stop(client)
  end

  def receive_message(client_pid, message) when is_pid(client_pid) do
    GenServer.call(client_pid, {:receive_message, message})
  end

  def start_link(%__MODULE__{} = client) do
    GenServer.start_link(__MODULE__, client, [])
  end

  def start_link(callback_module, pid_or_port) when is_pid(pid_or_port) or is_port(pid_or_port) do
    {:ok, player_uuid, player_pid} = Player.create()

    client = %__MODULE__{
      socket: pid_or_port,
      entrypoint_module: callback_module,
      player_uuid: player_uuid,
      player_pid: player_pid,
      unique_ref: make_ref()
    }

    GenServer.start_link(__MODULE__, client, [])
  end

  def init(client) do
    new_client = %__MODULE__{
      client |
      client_pid: self()
    }

    Fluxspace.Entrypoints.ClientGroup.add_client(new_client)

    {:ok, new_client}
  end

  def handle_call({:send_message, message}, _from, client) do
    client.entrypoint_module.send_message(client, message)
    {:reply, :ok, client}
  end

  def handle_call({:receive_message, message}, _from, client) do
    normalized_message = normalize_message(message)

    if length(client.callbacks) > 0 do
      [callback | callbacks] = client.callbacks

      send(callback, {:message, normalized_message})

      new_client = %__MODULE__{
        client |
        callbacks: callbacks
      }

      {:reply, :ok, new_client}
    else
      Fluxspace.Commands.Index.do_command(normalized_message, client)

      {:reply, :ok, client}
    end
  end

  def handle_call({:register_callback, pid}, _from, client) do
    new_client = %__MODULE__{
      client |
      callbacks: [pid | client.callbacks]
    }

    {:reply, :ok, new_client}
  end

  def handle_call({:enter_menu, menu_module}, _from, client) do
    menu_module.call(client)

    {:reply, :ok, client}
  end

  def terminate(_reason, client) do
    Fluxspace.Entrypoints.ClientGroup.remove_client(client)
  end

  def normalize_message(message) do
    String.trim(message)
  end
end
