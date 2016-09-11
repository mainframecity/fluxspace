defmodule Fluxspace.PlayerRegistryTest do
  use ExUnit.Case
  alias Fluxspace.Structs.Player

  test "Can add a player" do
    player = %Player{uuid: "1234"}
    assert :ok == Fluxspace.PlayerRegistry.add_player(player)
  end

  test "Can remove a player" do
    player = %Player{uuid: "1234"}
    assert player == Fluxspace.PlayerRegistry.remove_player(player)
  end
end
