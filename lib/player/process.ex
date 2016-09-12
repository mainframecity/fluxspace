defmodule Fluxspace.Player.Process do
  @moduledoc """
  Manages interactions with a player. Every player
  has one of these processes to manage state.
  """

  use GenServer

  alias Fluxspace.Structs.{Player, Inventory}

  def start_link(player, opts \\ []) do
    state = %{
      "player" => player,
      "inventory" => %Inventory{}
    }

    GenServer.start_link(__MODULE__, state, opts)
  end

  def get_inventory(pid, player) do
    GenServer.call(pid, :get_inventory)
  end

  # ---
  # GenServer Callbacks
  # ---

  def handle_call(:get_inventory, _from, state) do
    {:reply, state["inventory"], state}
  end
end
