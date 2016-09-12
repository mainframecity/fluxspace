defmodule Fluxspace.Player.RegistryTest do
  use ExUnit.Case
  alias Fluxspace.Structs.Player

  test "Can add a player" do
    player = %Player{uuid: "1234"}
    assert :ok == Fluxspace.Player.Registry.add_player(player)
  end

  test "Can remove a player" do
    player = %Player{uuid: "1234"}
    assert player == Fluxspace.Player.Registry.remove_player(player)
  end
end
