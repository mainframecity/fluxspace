defmodule Fluxspace.Entrypoints.Websocket do
  def send_message(client, message) do
    send(client.socket, {:send_message, message})
  end
end
