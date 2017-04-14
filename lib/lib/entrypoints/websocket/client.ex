defmodule Fluxspace.Entrypoints.Websocket.Client do
  @behaviour :cowboy_websocket_handler

  alias Fluxspace.Entrypoints.Client

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_terminate(_reason, _req, client) do
    Client.stop(client)
    :ok
  end

  def websocket_init(_transport_name, req, _opts) do
    {:ok, client_pid} = Client.start_link(self())

    Client.enter_menu(client_pid, Fluxspace.Menus.Login)

    {:ok, req, client_pid}
  end

  def websocket_handle({:text, message}, req, client) do
    Client.receive_message(client, message)

    {:reply, {:text, ""}, req, client}
  end

  def websocket_handle(_frame, req, client) do
    {:ok, req, client}
  end

  def websocket_info({:send_message, message}, req, client) do
    {:reply, {:text, message}, req, client}
  end

  def websocket_info(:close, req, client) do
    {:shutdown, req, client}
  end

  def websocket_info(_info, req, client) do
    {:ok, req, client}
  end
end
