defmodule Fluxspace.TCP.SocketGroup do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], [])
  end

  def add_socket(pid, socket) do
    GenServer.call(pid, {:add_socket, socket})
  end

  def remove_socket(pid, socket) do
    GenServer.call(pid, {:remove_socket, socket})
  end

  def broadcast_message(pid, message) do
    GenServer.call(pid, {:broadcast_message, message})
  end

  def handle_call({:add_socket, socket}, _from, state) do
    new_state = [socket | state]
    {:reply, :ok, new_state}
  end

  def handle_call({:remove_socket, socket}, _from, state) do
    new_state = state |> Enum.reject(fn(compared_socket) ->
      compared_socket == socket
    end)

    {:reply, :ok, new_state}
  end

  def handle_call({:broadcast_message, message}, _from, state) do
    state |> Enum.each(fn(socket) ->
      :gen_tcp.send(socket, message)
    end)

    {:reply, :ok, state}
  end
end

defmodule Fluxspace.TCP.Server do
  @port 4040

  def start_link(_state, _args) do
    {:ok, spawn(&init/0)}
  end

  def init() do
    {:ok, socket} = :gen_tcp.listen(@port, [:binary, packet: 0, active: false, reuseaddr: true])
    {:ok, socket_group} = Fluxspace.TCP.SocketGroup.start_link()

    IO.puts("Started TCP server on #{@port}")

    loop_acceptor({socket_group, socket})
  end

  def loop_acceptor({socket_group, socket}) do
    {:ok, client_socket} = :gen_tcp.accept(socket)
    {:ok, _client} = Fluxspace.TCP.Client.start_link(socket_group, client_socket)

    loop_acceptor({socket_group, socket})
  end
end
