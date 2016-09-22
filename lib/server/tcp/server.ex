defmodule Fluxspace.TCP.Server do
  @port 4040

  def start_link(_state, _args) do
    {:ok, spawn(&init/0)}
  end

  def init() do
    {:ok, socket} = :gen_tcp.listen(@port, [:binary, packet: 0, active: false, reuseaddr: true])

    loop_acceptor(socket)
  end

  def loop_acceptor(socket) do
    {:ok, client_socket} = :gen_tcp.accept(socket)
    {:ok, _client} = Fluxspace.TCP.Client.start_link(client_socket)
    loop_acceptor(socket)
  end
end
