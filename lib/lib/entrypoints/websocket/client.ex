defmodule Fluxspace.Entrypoints.Websocket.Client do
  @behaviour :cowboy_websocket_handler

  alias Fluxspace.Lib.Player
  alias Fluxspace.Entrypoints.Client

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_terminate(_reason, _req, state) do
    Fluxspace.Entrypoints.ClientGroup.remove_client(state)
    :ok
  end

  def websocket_init(_transport_name, req, _opts) do
    {:ok, player_uuid, player_pid} = Player.create

    client = %Client{
      socket: self(),
      entrypoint_module: Fluxspace.Entrypoints.Websocket,
      player_uuid: player_uuid,
      player_pid: player_pid
    }

    Fluxspace.Entrypoints.ClientGroup.add_client(client)

    {:ok, req, client}
  end

  def websocket_handle({:text, message}, req, state) do
    formatted_message = String.trim(message)
    Fluxspace.Commands.Index.do_command(formatted_message, state)

    {:reply, {:text, ""}, req, state}
  end

  def websocket_handle(_frame, _req, state) do
    {:ok, state}
  end

  def websocket_info({:send_message, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_info(_info, _req, state) do
    {:ok, state}
  end
end
