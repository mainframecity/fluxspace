defmodule Fluxspace.Entrypoints.ClientGroup do
  @moduledoc """
  Temporary module to hold all the Clients that exist in the game.
  """

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def add_client(client) do
    GenServer.call(__MODULE__, {:add_client, client})
  end

  def remove_client(client) do
    GenServer.call(__MODULE__, {:remove_client, client})
  end

  def broadcast_message(message) do
    GenServer.call(__MODULE__, {:broadcast_message, message})
  end

  def handle_call({:add_client, client}, _from, state) do
    new_state = [client | state]
    {:reply, :ok, new_state}
  end

  def handle_call({:remove_client, client}, _from, state) do
    new_state = state |> Enum.reject(fn(compared_client) ->
      compared_client.player_uuid == client.player_uuid
    end)

    {:reply, :ok, new_state}
  end

  def handle_call({:broadcast_message, message}, _from, state) do
    state |> Enum.each(fn(client) ->
      if client.entrypoint_module do
        client.entrypoint_module.send_message(client, message)
      end
    end)

    {:reply, :ok, state}
  end
end
