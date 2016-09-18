alias Fluxspace.Entity

defmodule Fluxspace.Server do
  use GenServer

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args)
  end

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
    IO.puts "Spawned #{uuid}"

    accept(state)
  end

  def handle_cast({:handle_command, "kill " <> uuid}, state) do
    case Entity.kill(uuid) do
      :error -> IO.puts "Could not find entity under uuid: #{uuid}"
      :ok -> IO.puts "Entity killed"
    end

    accept(state)
  end

  def handle_cast({:handle_command, _command}, state) do
    IO.puts("Unrecognized command")

    accept(state)
  end
end
