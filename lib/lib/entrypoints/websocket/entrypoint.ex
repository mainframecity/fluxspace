defmodule Fluxspace.Entrypoints.Websocket do
  def send_message(client, message) do
    send(client.socket, {:send_message, message})
  end

  def close(client) do
    send(client.socket, :close)
  end
end
