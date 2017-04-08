defmodule Fluxspace.Entrypoints.TCP.Client do
  alias Fluxspace.Lib.Player
  alias Fluxspace.Entrypoints.Client

  def start_link(socket) do
    client_pid = spawn_link(fn() ->
      {:ok, player_uuid, player_pid} = Player.create()

      client = %Client{
        socket: socket,
        entrypoint_module: Fluxspace.Entrypoints.TCP,
        player_uuid: player_uuid,
        player_pid: player_pid,
        unique_ref: make_ref()
      }

      {:ok, client_pid} = Client.start_link(client)

      new_client = %Client{
        client |
        client_pid: client_pid
      }

      serve(new_client)
    end)

    {:ok, client_pid}
  end

  def serve(%Client{initialized: false} = client) do
    Fluxspace.Menus.Login.call(client)

    serve(%Client{client | initialized: true})
  end

  def serve(%Client{halted: true} = client) do
    Client.stop(client)
    :stop
  end

  def serve(client) do
    case read_socket(client.socket) do
      {:ok, data} ->
        handle_message(data, client)
        serve(client)
      _ ->
        serve(%Client{client | halted: true})
    end
  end

  # ---
  # IO
  # ---

  def read_socket(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        {:ok, data}
      {:error, :timeout} ->
        {:ok, ""}
      _ -> :error
    end
  end

  def handle_message(<<255, 253, 1, 255, 253, 3>>, client), do: {:ok, client}
  def handle_message(<<255, 252, 1, 255, 251, 3>>, client), do: {:ok, client}
  def handle_message(<<255, 254, 1>>, client), do: {:ok, client}

  def handle_message(message, client) do
    Client.receive_message(client, message)
  end
end
