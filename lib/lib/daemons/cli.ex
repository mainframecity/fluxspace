alias Fluxspace.Entity
alias Fluxspace.Lib.Attributes.Appearance
alias Fluxspace.Lib.Daemon

defmodule Fluxspace.Lib.Daemons.CLI do
  use Daemon

  def init(_args) do
    IO.puts "[fluxspace] booting.."
    GenServer.cast(self, :accept_command)

    {:ok, []}
  end

  # ---
  # Callbacks
  # ---

  def accept(state) do
    GenServer.cast(self, :accept_command)
    {:noreply, state}
  end

  def handle_cast(:accept_command, state) do
    command = IO.gets("[fluxspace] > ") |> String.trim
    GenServer.cast(self, {:handle_command, command})

    {:noreply, state}
  end

  def handle_cast({:handle_command, "spawn"}, state) do
    {:ok, uuid, _} = Fluxspace.Entity.start()
    IO.puts "Spawned: #{uuid}"

    accept(state)
  end

  def handle_cast({:handle_command, "spawn room"}, state) do
    {:ok, uuid, _} = Fluxspace.Lib.Room.create
    IO.puts "Spawned Room: #{uuid}"

    accept(state)
  end

  def handle_cast({:handle_command, "spawn npc"}, state) do
    {:ok, uuid, _} = Fluxspace.Lib.NPC.create
    IO.puts "Spawned NPC: #{uuid}"

    accept(state)
  end

  def handle_cast({:handle_command, "kill " <> uuid}, state) do
    case Entity.kill(uuid) do
      :error -> IO.puts "Could not find entity under uuid: #{uuid}"
      :ok -> IO.puts "Entity killed"
    end

    accept(state)
  end

  def handle_cast({:handle_command, "describe " <> uuid}, state) do
    case Entity.exists?(uuid) do
      false -> IO.puts "Could not find entity under uuid: #{uuid}"
      true ->
        Appearance.get_short_description(uuid)
        |> IO.puts()
    end

    accept(state)
  end

  def handle_cast({:handle_command, _command}, state) do
    IO.puts("Unrecognized command")

    accept(state)
  end
end
