defmodule Fluxspace.Entrypoints.TCP do
  def send_message(client, message) do
    :gen_tcp.send(client.socket, message)
  end

  def close(client) do
    :gen_tcp.close(client.socket)
  end
end
