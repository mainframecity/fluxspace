defmodule Fluxspace.Entrypoints.TCP.SocketGroup do
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
