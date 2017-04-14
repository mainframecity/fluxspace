defmodule Fluxspace.Entrypoints.TCP.Client do
  alias Fluxspace.Entrypoints.Client

  use GenServer

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket, [])
  end

  def init(socket) do
    {:ok, client_pid} = Client.start_link(self())

    Client.enter_menu(client_pid, Fluxspace.Menus.Login)

    {:ok, {socket, client_pid}}
  end

  def handle_info({:tcp, _socket, message}, {_, client} = state) do
    handle_message(client, message)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, {_, client_pid} = state) do
    Client.stop(client_pid)
    {:stop, :normal, state}
  end

  def handle_info({:send_message, message}, {socket, _} = state) do
    :gen_tcp.send(socket, message)
    {:noreply, state}
  end

  def handle_info(:close, {socket, _} = state) do
    :gen_tcp.close(socket)
    {:stop, :normal, state}
  end

  def handle_message(client, <<255, 253, 1, 255, 253, 3>>), do: {:ok, client}
  def handle_message(client, <<255, 252, 1, 255, 251, 3>>), do: {:ok, client}
  def handle_message(client, <<255, 254, 1>>), do: {:ok, client}

  def handle_message(client, message) do
    Client.receive_message(client, message)
  end
end
