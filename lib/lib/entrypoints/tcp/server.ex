defmodule Fluxspace.Entrypoints.TCP.Server do
  @port 4040

  def start_link(_state, _args) do
    {:ok, spawn_link(&init/0)}
  end

  def init() do
    {:ok, socket} = :gen_tcp.listen(@port, [:binary, packet: 0, active: false, reuseaddr: true])

    IO.puts("Started TCP server on #{@port}")

    loop_acceptor(socket)
  end

  def loop_acceptor(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client_socket} ->
        Fluxspace.Entrypoints.TCP.Client.start_link(client_socket)
      _ -> :ok
    end

    loop_acceptor(socket)
  end
end
