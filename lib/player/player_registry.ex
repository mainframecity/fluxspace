defmodule Fluxspace.PlayerRegistry do
  @moduledoc """
  Manages the current location of a player entity.
  (The PID of the current Region and current Room)
  """

  use GenServer

  def start_link(state \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end
end
