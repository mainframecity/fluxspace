defmodule Fluxspace.Entrypoints.Websocket.Client do
  @behaviour :cowboy_websocket_handler

  alias Fluxspace.Lib.Player
  alias Fluxspace.Entrypoints.Client

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_terminate(_reason, _req, client) do
    Client.stop(client)
    :ok
  end

  def websocket_init(_transport_name, req, _opts) do
    {:ok, player_uuid, player_pid} = Player.create

    client = %Client{
      socket: self(),
      entrypoint_module: Fluxspace.Entrypoints.Websocket,
      player_uuid: player_uuid,
      player_pid: player_pid,
      unique_ref: make_ref()
    }

    {:ok, client_pid} = Client.start_link(client)

    new_client = %Client{
      client |
      client_pid: client_pid
    }

    {:ok, req, new_client}
  end

  def websocket_handle({:text, message}, req, client) do
    Client.receive_message(client, message)
    {:reply, {:text, ""}, req, client}
  end

  def websocket_handle(_frame, _req, client) do
    {:ok, client}
  end

  def websocket_info({:send_message, message}, req, client) do
    {:reply, {:text, message}, req, client}
  end

  def websocket_info(_info, _req, client) do
    {:ok, client}
  end
end
