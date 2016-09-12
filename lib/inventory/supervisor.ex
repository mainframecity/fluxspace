defmodule Fluxspace.Inventory.Supervisor do
  @moduledoc """
  This manages the inventories for every player and handles
  persistance/interactions.
  """

  use GenServer

  def start_link(_state, opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end
end
