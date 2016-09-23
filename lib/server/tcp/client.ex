defmodule Fluxspace.TCP.Client do
  use GenServer

  alias Fluxspace.TCP.Client

  defstruct [
    socket: nil,
    halted: false,
    initialized: false,
    x: 1,
    y: 1
  ]

  @map [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  ]

  def start_link(socket) do
    {:ok, spawn(fn() -> serve(%Client{socket: socket}) end)}
  end

  def serve(%Client{initialized: false} = client) do
    :gen_tcp.send(client.socket, <<255, 251, 1>>)
    :gen_tcp.send(client.socket, <<255, 251, 3>>)

    serve(%Client{client | initialized: true})
  end

  def serve(%Client{halted: true}), do: nil
  def serve(client) do
    :gen_tcp.send(client.socket, "\e[2J")
    :gen_tcp.send(client.socket, serialize_map(client))

    with {:ok, data} <- read_socket(client.socket),
      {:ok, new_client} <- handle_message(data, client) do
        serve(new_client)
    else
      _ -> serve(%Client{client | halted: true})
    end
  end

  # ---
  # Translation
  # ---

  def serialize_map(client) do
    fov_map =
      @map
      |> Fluxspace.FOV.calculate_fov({client.x, client.y}, 4)

    @map
    |> Enum.zip(fov_map)
    |> Enum.map(fn({u, v}) ->
      u
      |> Enum.zip(v)
      |> Enum.map(fn({x, y}) ->
        x*y
      end)
    end)
    |> Enum.with_index()
    |> Enum.map(fn({row, row_idx}) ->
       [row
       |> Stream.with_index()
       |> Enum.map(fn({col, col_idx}) ->
         if row_idx == client.y and col_idx == client.x do
           "@"
         else
           tile_to_ascii(col)
         end
       end)| ["\r\n"]]
     end)
  end

  def tile_to_ascii(tile) do
    case tile do
      1 -> "#"
      0 -> "\e[30m.\e[37m"
    end
  end

  # ---
  # IO
  # ---

  def read_socket(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        {:ok, data}
      _ -> :error
    end
  end

  def handle_message(<<255, 253, 1, 255, 253, 3>>, client), do: {:ok, client}
  def handle_message(<<255, 252, 1, 255, 251, 3>>, client), do: {:ok, client}
  def handle_message(<<255, 254, 1>>, client), do: {:ok, client}

  # ORIGIN IS TOP-LEFT OF SCREEN

  # N
  def handle_message("k", client) do
    {:ok, %Client{client | y: client.y - 1}}
  end

  # NE
  def handle_message("u", client) do
    {:ok, %Client{client | y: client.y - 1, x: client.x + 1}}
  end

  # E
  def handle_message("l", client) do
    {:ok, %Client{client | x: client.x + 1}}
  end

  # SE
  def handle_message("n", client) do
    {:ok, %Client{client | y: client.y + 1, x: client.x + 1}}
  end

  # S
  def handle_message("j", client) do
    {:ok, %Client{client | y: client.y + 1}}
  end

  # SW
  def handle_message("b", client) do
    {:ok, %Client{client | y: client.y + 1, x: client.x - 1}}
  end

  # W
  def handle_message("h", client) do
    {:ok, %Client{client | x: client.x - 1}}
  end

  # NW
  def handle_message("y", client) do
    {:ok, %Client{client | y: client.y - 1, x: client.x - 1}}
  end

  def handle_message(_message, client), do: {:ok, client}
end
