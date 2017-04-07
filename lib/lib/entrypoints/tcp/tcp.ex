defmodule Fluxspace.Entrypoints.TCP do
  @port 4040

  def start_link(_state, _args) do
    {:ok, spawn(&init/0)}
  end

  def init() do
    {:ok, socket} = :gen_tcp.listen(@port, [:binary, packet: 0, active: false, reuseaddr: true])
    {:ok, socket_group} = Fluxspace.Entrypoints.TCP.SocketGroup.start_link()

    IO.puts("Started TCP server on #{@port}")

    loop_acceptor({socket_group, socket})
  end

  def loop_acceptor({socket_group, socket}) do
    {:ok, client_socket} = :gen_tcp.accept(socket)
    {:ok, _client} = Fluxspace.Entrypoints.TCP.Client.start_link(socket_group, client_socket)

    loop_acceptor({socket_group, socket})
  end
end
