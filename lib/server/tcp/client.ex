defmodule Fluxspace.TCP.Client do
  use GenServer

  alias Fluxspace.Lib.Player
  alias Fluxspace.TCP.Client
  alias Fluxspace.Lib.Attributes.Locality

  defstruct [
    player_uuid: "",
    player_pid: nil,
    socket: nil,
    halted: false,
    initialized: false
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
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
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
    client_pid = spawn(fn() ->
      {:ok, player_uuid, player_pid} = Player.create

      serve(%Client{socket: socket, player_uuid: player_uuid, player_pid: player_pid})
    end)

    {:ok, client_pid}
  end

  def serve(%Client{initialized: false} = client) do
    :gen_tcp.send(client.socket, <<255, 251, 1>>)
    :gen_tcp.send(client.socket, <<255, 251, 3>>)

    :pg2.create("TCP")
    :pg2.join("TCP", client.player_pid)

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


  def get_player_pids() do
    :pg2.get_members("TCP")
  end

  # ---
  # Translation
  # ---

  def serialize_map(client) do
    {player_x, player_y} = Locality.get_location(client.player_pid)

    player_coordinates =
      get_player_pids()
      |> Enum.map(fn(player_pid) ->
        Locality.get_location(player_pid)
      end)

    fov_map =
      @map
      |> Fluxspace.FOV.calculate_fov({player_x, player_y}, 4)

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
         if Enum.any?(player_coordinates, &(&1 == {col_idx, row_idx})) do
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
    case :gen_tcp.recv(socket, 0, 100) do
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

  # ORIGIN IS TOP-LEFT OF SCREEN

  # N
  def handle_message("k", client) do
    client.player_pid |> Locality.modify_location(:y, :dec)
    {:ok, client}
  end

  # NE
  def handle_message("u", client) do
    client.player_pid |> Locality.modify_location(:y, :dec)
    client.player_pid |> Locality.modify_location(:x, :inc)
    {:ok, client}
  end

  # E
  def handle_message("l", client) do
    client.player_pid |> Locality.modify_location(:x, :inc)
    {:ok, client}
  end

  # SE
  def handle_message("n", client) do
    client.player_pid |> Locality.modify_location(:y, :inc)
    client.player_pid |> Locality.modify_location(:x, :inc)
    {:ok, client}
  end

  # S
  def handle_message("j", client) do
    client.player_pid |> Locality.modify_location(:y, :inc)
    {:ok, client}
  end

  # SW
  def handle_message("b", client) do
    client.player_pid |> Locality.modify_location(:y, :inc)
    client.player_pid |> Locality.modify_location(:x, :dec)
    {:ok, client}
  end

  # W
  def handle_message("h", client) do
    client.player_pid |> Locality.modify_location(:x, :dec)
    {:ok, client}
  end

  # NW
  def handle_message("y", client) do
    client.player_pid |> Locality.modify_location(:y, :dec)
    client.player_pid |> Locality.modify_location(:x, :dec)
    {:ok, client}
  end

  def handle_message(_message, client), do: {:ok, client}
end
