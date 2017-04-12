defmodule Fluxspace.Entrypoints.TCP.Server do
  @port 4040

  def start_link(_state, _args) do
    {:ok, spawn_link(&init/0)}
  end

  def init() do
    {:ok, listen_socket} = :gen_tcp.listen(@port, [:binary, packet: 0, active: false, reuseaddr: true])

    IO.puts("Started TCP server on #{@port}")

    loop_acceptor(listen_socket)
  end

  def loop_acceptor(listen_socket) do
    case :gen_tcp.accept(listen_socket) do
      {:ok, client_socket} ->
        {:ok, entrypoint_client_pid} = Fluxspace.Entrypoints.TCP.Client.start_link(client_socket)
        :ok = :gen_tcp.controlling_process(client_socket, entrypoint_client_pid)
        :ok = :inet.setopts(client_socket, [{:active, true}])
      _ ->
        :ok
    end

    loop_acceptor(listen_socket)
  end
end
