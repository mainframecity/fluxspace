alias Fluxspace.Lib.Daemon

defmodule Fluxspace.Lib.Daemons.Region do
  @moduledoc """
  This module is responsible for registering and interacting with Maps (groups
  of rooms).
  """

  use Daemon

  def add_map(map) do
    GenServer.cast(__MODULE__, {:add_map, map})
  end

  def remove_map(map) do
    GenServer.cast(__MODULE__, {:remove_map, map})
  end

  def add_room_to_map(map, room) do
    GenServer.cast(__MODULE__, {:add_room_to_map, map, room})
  end

  def remove_room_from_map(map, room) do
    GenServer.cast(__MODULE__, {:remove_room_from_map, map, room})
  end

  def get_maps() do
    GenServer.call(__MODULE__, :get_maps)
  end

  def get_rooms_from_map(map) do
    GenServer.call(__MODULE__, {:get_rooms_from_map, map})
  end

  # ---
  # GenServer Callbacks
  # ---

  def handle_cast({:add_map, _map}, state) do
    {:noreply, state}
  end

  def handle_cast({:remove_map, _map}, state) do
    {:noreply, state}
  end

  def handle_cast({:add_room_to_map, _map, _room}, state) do
    {:noreply, state}
  end

  def handle_cast({:remove_room_from_map, _map, _room}, state) do
    {:noreply, state}
  end

  def handle_call(:get_maps, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_rooms_from_map, _map}, _from, state) do
    {:reply, state, state}
  end
end
