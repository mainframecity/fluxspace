defmodule Fluxspace.Entrypoints.TCP.Client do
  use GenServer

  alias Fluxspace.Lib.Player
  alias Fluxspace.Entrypoints.TCP.Client

  @help """
  ------------------------------
  Welcome to Fluxspace.

  help - Display this message.
  say <message> - Say a message.
  ------------------------------

  """

  defstruct [
    player_uuid: "",
    player_pid: nil,
    socket: nil,
    socket_group: nil,
    halted: false,
    initialized: false
  ]

  def start_link(socket_group, socket) do
    client_pid = spawn(fn() ->
      {:ok, player_uuid, player_pid} = Player.create

      client = %Client{
        socket: socket,
        socket_group: socket_group,
        player_uuid: player_uuid,
        player_pid: player_pid
      }

      Fluxspace.Entrypoints.TCP.SocketGroup.add_socket(client.socket_group, client.socket)

      serve(client)
    end)

    {:ok, client_pid}
  end

  def serve(%Client{initialized: false} = client) do
    do_command("help", client)

    serve(%Client{client | initialized: true})
  end

  def serve(%Client{halted: true} = client) do
    Fluxspace.Entrypoints.TCP.SocketGroup.remove_socket(client.socket_group, client.socket)
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

  def send_message(client, message) do
    :gen_tcp.send(client.socket, [message, "\n"])
    {:ok, client}
  end

  def broadcast_message(client, message) do
    Fluxspace.Entrypoints.TCP.SocketGroup.broadcast_message(client.socket_group, message)
    {:ok, client}
  end

  # ---
  # Commands
  # ---

  def do_command("help", client) do
    send_message(client, @help)
  end

  def do_command("say " <> message, client) do
    formatted_message = [
      "\n",
      client.player_uuid,
      " says: ",
      message,
      "\n"
    ]

    broadcast_message(client, formatted_message)
  end

  def do_command(_message, client), do: {:error, client}

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

    case do_command(normalized_message, client) do
      {:ok, client} ->
        {:ok, client}
      _ ->
        send_message(client, "I'm sorry, what?")
        {:ok, client}
    end
  end

  def normalize_message(message) do
    String.strip(message)
  end
end
