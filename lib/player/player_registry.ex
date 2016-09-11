defmodule Fluxspace.PlayerRegistry do
  @moduledoc """
  Manages the current location of a player entity.
  (The PID of the current Region and current Room)
  """

  use GenServer

  def start_link(_state, opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def add_player(player) do
    GenServer.cast(__MODULE__, {:add_player, player})
  end

  def remove_player(player) do
    GenServer.call(__MODULE__, {:remove_player, player})
  end

  def get_player(player) do
    GenServer.call(__MODULE__, {:get_player, player})
  end

  def handle_cast({:add_player, player}, state) do
    {:noreply, Map.put(state, player.uuid, self())}
  end

  def handle_call({:remove_player, player}, _from, state) do
    {:reply, player, Map.delete(state, player.uuid)}
  end

  def handle_call({:get_player, player}, _from, state) do
    {:reply, Map.get(state, player.uuid), state}
  end
end
