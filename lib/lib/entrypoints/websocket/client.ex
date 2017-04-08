defmodule Fluxspace.Entrypoints.Websocket.Client do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end

  def websocket_init(_transport_name, req, _opts) do
    {:ok, req, []}
  end

  def websocket_handle({:text, _content}, req, state) do
    {:reply, {:text, ""}, req, state}
  end

  def websocket_handle(_frame, _req, state) do
    {:ok, state}
  end

  def websocket_info(_info, _req, state) do
    {:ok, state}
  end
end
