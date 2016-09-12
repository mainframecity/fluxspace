defmodule Fluxspace.Player.ProcessTest do
  use ExUnit.Case

  alias Fluxspace.Player.Process, as: PlayerProcess
  alias Fluxspace.Structs.{Player, Inventory}

  test "Can get inventory for player" do
    player = %Player{uuid: "1234"}
    inventory = %Inventory{}
    {:ok, pid} = PlayerProcess.start_link(player)

    assert inventory == PlayerProcess.get_inventory(pid, player)
  end
end
