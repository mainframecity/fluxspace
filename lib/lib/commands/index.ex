defmodule Fluxspace.Commands.Index do
  alias Fluxspace.Entrypoints.{Client, ClientGroup}

  @help """
  ------------------------------
  Welcome to Fluxspace.

  help - Display this message.
  say <message> - Say a message.
  look - Look around the room.
  look at <name> - Look at a thing.
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

    ClientGroup.broadcast_message(client, formatted_message)

    {:ok, client}
  end

  def do_command("logout", client, player_pid) do
    name = Fluxspace.Lib.Attributes.Appearance.get_name(player_pid)
    ClientGroup.broadcast_message(client, "#{name} logged out.\n")
    Client.stop_all(client)

    {:ok, client}
  end

  def do_command("look", client, player_pid) do
    room_pid = ClientGroup.get_room()
    players = Fluxspace.Lib.Room.get_entities(room_pid)
    player_names = Enum.map(players, fn(player_pid) ->
        Fluxspace.Lib.Attributes.Appearance.get_name(player_pid)
      end)
      |> Enum.join(", ")

    room_description = Fluxspace.Lib.Attributes.Appearance.get_long_description(room_pid)

    name = Fluxspace.Lib.Attributes.Appearance.get_name(player_pid)
    ClientGroup.broadcast_message(client, "#{name} looks around the room.\n")

    Client.send_message(client, "#{room_description} It contains: #{player_names}\n")
  end

  def do_command("look at " <> entity_name, client, player_pid) do
    calling_name = Fluxspace.Lib.Attributes.Appearance.get_name(player_pid)
    room_pid = ClientGroup.get_room()
    entities = Fluxspace.Lib.Room.get_entities(room_pid)
    entities_with_name = Stream.map(entities, fn(entity_pid) ->
        {entity_pid, Fluxspace.Lib.Attributes.Appearance.get_name(entity_pid)}
      end)
      |> Stream.reject(fn({_, name}) -> is_nil(name) end)
      |> Stream.map(fn({entity_pid, name}) ->
        {entity_pid, name, String.jaro_distance(entity_name, name)}
      end)
      |> Enum.to_list()
      |> Enum.sort(fn({_, _, first_distance}, {_, _, second_distance}) -> first_distance >= second_distance end)

    case entities_with_name do
      [] ->
        Client.send_message(client, "There doesn't seem to be anything here by that name.\r\n")
      _ ->
        {entity_pid, real_entity_name, _} = hd(entities_with_name)
        entity_description = Fluxspace.Lib.Attributes.Appearance.get_long_description(entity_pid)

        Client.send_message(client, "You look at #{real_entity_name}. #{entity_description}\r\n")
        Fluxspace.Lib.Attributes.Clientable.send_message(entity_pid, "#{calling_name} looks at you.\r\n")
    end
  end

  def do_command(_, client, _) do
    Client.send_message(client, "I'm sorry, what?")

    {:error, client}
  end
end
