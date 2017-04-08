defmodule Fluxspace.Entrypoints.TCP.Client do
  use GenServer

  alias Fluxspace.Lib.Player
  alias Fluxspace.Entrypoints.Client

  def start_link(socket) do
    client_pid = spawn(fn() ->
      {:ok, player_uuid, player_pid} = Player.create

      client = %Client{
        socket: socket,
        entrypoint_module: Fluxspace.Entrypoints.TCP,
        player_uuid: player_uuid,
        player_pid: player_pid
      }

      Fluxspace.Entrypoints.ClientGroup.add_client(client)

      serve(client)
    end)

    {:ok, client_pid}
  end

  def serve(%Client{initialized: false} = client) do
    Fluxspace.Commands.Index.do_command("help", client)

    serve(%Client{client | initialized: true})
  end

  def serve(%Client{halted: true} = client) do
    Fluxspace.Entrypoints.ClientGroup.remove_client(client)
  end

  def serve(client) do
    :gen_tcp.send(client.socket, "> ")

    with {:ok, data} <- read_socket(client.socket),
      {:ok, new_client} <- handle_message(data, client) do
        serve(new_client)
    else
      _ -> serve(%Client{client | halted: true})
    end
  end

  # ---
  # Commands
  # ---

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
    normalized_message = normalize_message(message)
    Fluxspace.Commands.Index.do_command(normalized_message, client)
  end

  def normalize_message(message) do
    String.strip(message)
  end
end
