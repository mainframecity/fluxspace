defmodule Fluxspace.Entrypoints.Client do
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
    send(client.client_pid, {:register_callback, pid})

    receive do
      {:message, message} -> message
      _ -> :error
    end
  end

  def send_message(client, message) do
    client.entrypoint_module.send_message(client, message)
  end

  def normalize_message(message) do
    String.trim(message)
  end

  def stop(%__MODULE__{} = client) do
    GenServer.stop(client.client_pid)
  end

  def close(%__MODULE__{} = client) do
    client.entrypoint_module.close(client)
    stop(client)
  end

  def receive_message(%__MODULE__{} = client, message) do
    send(client.client_pid, {:receive_message, message})
  end

  def start_link(%__MODULE__{} = client) do
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

  def handle_info({:receive_message, message}, client) do
    normalized_message = normalize_message(message)

    if length(client.callbacks) > 0 do
      [callback | callbacks] = client.callbacks

      send(callback, {:message, normalized_message})

      new_client = %__MODULE__{
        client |
        callbacks: callbacks
      }

      {:noreply, new_client}
    else
      Fluxspace.Commands.Index.do_command(normalized_message, client)

      {:noreply, client}
    end
  end

  def handle_info({:register_callback, pid}, client) do
    new_client = %__MODULE__{
      client |
      callbacks: [pid | client.callbacks]
    }

    {:noreply, new_client}
  end

  def terminate(_reason, client) do
    Fluxspace.Entrypoints.ClientGroup.remove_client(client)
  end
end
