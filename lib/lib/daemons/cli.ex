defmodule Fluxspace.Lib.Daemons.CLI do
  alias Fluxspace.Lib.Daemons.CLI
  alias Fluxspace.Lib.Attributes.Appearance
  alias Fluxspace.Entity

  defstruct [
    buffer: "",
    history_index: 0,
    history: []
  ]

  @header """

     d'b 8
     8   8
    o8P  8 o    o `o  o' .oPYo. .oPYo. .oPYo. .oPYo. .oPYo.
     8   8 8    8  `bd'  Yb..   8    8 .oooo8 8    ' 8oooo8
     8   8 8    8  d'`b    'Yb. 8    8 8    8 8    . 8.
     8   8 `YooP' o'  `o `YooP' 8YooP' `YooP8 `YooP' `Yooo'
    \e[90m:..::..:.....:..:::..:.....:\e[39m8\e[90m ....::.....::.....::.....:
    ::::::::::::::::::::::::::::\e[39m8\e[90m ::::::::::::::::::::::::::
    ::::::::::::::::::::::::::::..::::::::::::::::::::::::::
    \e[39m

    (help) Help | (overview) Overview
  """

  def start_link(_state, _args) do
    {:ok, spawn(&init/0)}
  end

  def init() do
    @header
    |> IO.write()

    Port.open({:spawn, "tty_sl -c -e"}, [:binary])
    send(self(), :init)

    server_loop(%CLI{})
  end

  def prompt() do
    "[fluxspace] > " |> IO.write
  end

  def server_loop(state) do
    receive do
      :init ->
        "\n\e[k\e[G" |> IO.write
        prompt()
        server_loop(state)
      {_, {:data, data}} ->
        handle_char(data, state)
        |> server_loop()
      _ ->
        server_loop(state)
    end
  end

  # ---
  # Command Handlers
  # ---

  def handle_command("spawn") do
    {:ok, uuid, _} = Fluxspace.Entity.start()
    IO.write "Spawned: #{uuid}"
  end

  def handle_command("spawn room") do
    {:ok, uuid, _} = Fluxspace.Lib.Room.create
    IO.write "Spawned Room: #{uuid}"
  end

  def handle_command("spawn npc") do
    {:ok, uuid, _} = Fluxspace.Lib.NPC.create
    IO.write "Spawned NPC: #{uuid}"
  end

  def handle_command("kill " <> uuid) do
    case Entity.kill(uuid) do
      :error -> IO.write "Could not find entity under uuid: #{uuid}"
      :ok -> IO.write "Entity killed"
    end
  end

  def handle_command("describe " <> uuid) do
    case Entity.exists?(uuid) do
      false -> IO.write "Could not find entity under uuid: #{uuid}"
      true ->
        Appearance.get_short_description(uuid)
        |> IO.write()
    end
  end

  def handle_command("quit") do
    IO.write("Gently stopping Fluxspace...\n\e[k\e[G")
    :init.stop()
    :error
  end

  def handle_command(_command), do: "Unexpected command." |> IO.write

  # ---
  # Char Handlers
  # ---

  def handle_char("\d", %CLI{buffer: ""} = state), do: state
  def handle_char("\d", state) do
    "\e[1D\e[K" |> IO.write

    state
  end

  def handle_char("\e[A", state), do: state
  def handle_char("\e[B", state), do: state
  def handle_char("\e[C", state), do: state
  def handle_char("\e[D", state), do: state

  def handle_char("\r", state) do
    IO.write("\n\e[k\e[G")

    case state.buffer do
      "" ->
        IO.write("\e[k\e[G")
        prompt()
      "\n" ->
        IO.write("\e[k\e[G")
        prompt()
      _ ->
        case handle_command(state.buffer) do
          :error -> nil
          _ ->
            IO.write("\n\e[k\e[G")
            prompt()
        end
    end

    %CLI{state | buffer: "", history: [state.buffer | state.history]}
  end

  def handle_char(char, state) do
    IO.write(char)
    %CLI{state | buffer: state.buffer <> char}
  end
end
