defmodule Fluxspace.Commands.Index do
  alias Fluxspace.Entrypoints.{Client, ClientGroup}

  @help """
  ------------------------------
  Welcome to Fluxspace.

  help - Display this message.
  say <message> - Say a message.
  look - Look around the room.
  logout - Logs you out.
  ------------------------------

  """

  def do_command("help", client, _player_pid) do
    Client.send_message(client, @help)

    {:ok, client}
  end

  def do_command("say " <> message, client, player_pid) do
    name = Fluxspace.Lib.Attributes.Appearance.get_name(player_pid)

    formatted_message = [
      "\n",
      name,
      " says: ",
      message,
      "\n"
    ]

    ClientGroup.broadcast_message(formatted_message)

    {:ok, client}
  end

  def do_command("logout", client, player_pid) do
    name = Fluxspace.Lib.Attributes.Appearance.get_name(player_pid)
    ClientGroup.broadcast_message("#{name} logged out.\n")
    Client.stop_all(client)

    {:ok, client}
  end

  def do_command("look", client, _) do
    room_pid = ClientGroup.get_room()
    players = Fluxspace.Lib.Room.get_entities(room_pid)
    player_names = Enum.map(players, fn(player_pid) ->
        Fluxspace.Lib.Attributes.Appearance.get_name(player_pid)
      end)
      |> Enum.join(", ")

    Client.send_message(client, "You look around and you see: #{player_names}\n")
  end

  def do_command(_, client, _) do
    Client.send_message(client, "I'm sorry, what?")

    {:error, client}
  end
end
