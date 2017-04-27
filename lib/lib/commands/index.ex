defmodule Fluxspace.Commands.Index do
  use Fluxspace.Commands.Macros

  alias Fluxspace.Entrypoints.{Client, ClientGroup}
  alias Fluxspace.Lib.Attributes

  commands do
    command "spawn (?<name>.+), (?<description>.+)", &__MODULE__.spawn/4
    # command "say (?<message>.+)", &__MODULE__.say/4
    command "look at (?<subject>.+)", &__MODULE__.look_at/4
    command "look", &__MODULE__.look/4
    command "whisper to (?<subject>[^\s]+) (?<message>.+)", &__MODULE__.whisper_to/4
    command "logout", &__MODULE__.logout/4
    command "(.*?)", &__MODULE__.noop/4
  end

  def say(_, %{"message" => message}, _, player_pid) do
    room_pid = ClientGroup.get_room()
    name = Attributes.Appearance.get_name(player_pid)

    formatted_message = [
      "\n",
      name,
      " says, \"",
      message,
      "\"\n"
    ]

    Attributes.Clientable.send_message(player_pid, "You say, \"#{message}\".\r\n")
    Attributes.Inventory.notify_except(room_pid, player_pid, {:send_message, formatted_message})
  end

  def logout(_, _, client, player_pid) do
    room_pid = ClientGroup.get_room()
    name = Attributes.Appearance.get_name(player_pid)

    Attributes.Inventory.notify_except(room_pid, player_pid, {:send_message, "#{name} logged out.\r\n"})
    Client.stop_all(client)
  end

  def look(_, _, _, player_pid) do
    room_pid = ClientGroup.get_room()
    players = Fluxspace.Lib.Room.get_entities(room_pid)
    player_names = Enum.map(players, fn(entity_pid) ->
        name = Attributes.Appearance.get_name(entity_pid)

        if Fluxspace.Lib.Player.is_player?(entity_pid) do
          name
        else
          Fluxspace.Determiners.determine(name)
        end
      end)
      |> Enum.join(", ")

    room_description = Attributes.Appearance.get_long_description(room_pid)
    name = Attributes.Appearance.get_name(player_pid)

    Attributes.Inventory.notify_except(room_pid, player_pid, {:send_message, "#{name} looks around the room.\n"})
    Attributes.Clientable.send_message(player_pid, "#{room_description} It contains: #{player_names}\n")
  end

  def look_at(_, %{"subject" => entity_name}, _, player_pid) do
    calling_name = Attributes.Appearance.get_name(player_pid)
    room_pid = ClientGroup.get_room()
    entities = Fluxspace.Lib.Room.get_entities(room_pid)
    entities_with_name = Stream.map(entities, fn(entity_pid) ->
        {entity_pid, Attributes.Appearance.get_name(entity_pid)}
      end)
      |> Stream.reject(fn({_, name}) -> is_nil(name) end)
      |> Stream.map(fn({entity_pid, name}) ->
        {entity_pid, name, String.jaro_distance(entity_name, name)}
      end)
      |> Enum.to_list()
      |> Enum.sort(fn({_, _, first_distance}, {_, _, second_distance}) -> first_distance >= second_distance end)

    case entities_with_name do
      [] ->
        Attributes.Clientable.send_message(player_pid, "There doesn't seem to be anything here by that name.\r\n")
      _ ->
        {entity_pid, real_entity_name, _} = hd(entities_with_name)
        entity_description = Attributes.Appearance.get_long_description(entity_pid)

        Attributes.Clientable.send_message(player_pid, "You look at #{real_entity_name}. #{entity_description}\r\n")
        Attributes.Clientable.send_message(entity_pid, "#{calling_name} looks at you.\r\n")
        Fluxspace.Radio.notify(entity_pid, {:look_from, player_pid})
    end
  end

  def whisper_to(_, %{"subject" => subject, "message" => message}, _, player_pid) do
    calling_name = Attributes.Appearance.get_name(player_pid)
    room_pid = ClientGroup.get_room()
    entities = Fluxspace.Lib.Room.get_entities(room_pid)
    entities_with_name = Stream.map(entities, fn(entity_pid) ->
        {entity_pid, Attributes.Appearance.get_name(entity_pid)}
      end)
      |> Stream.reject(fn({_, name}) -> is_nil(name) end)
      |> Stream.map(fn({entity_pid, name}) ->
        {entity_pid, name, String.jaro_distance(subject, name)}
      end)
      |> Enum.to_list()
      |> Enum.sort(fn({_, _, first_distance}, {_, _, second_distance}) -> first_distance >= second_distance end)

    case entities_with_name do
      [] ->
        Attributes.Clientable.send_message(player_pid, "There doesn't seem to be anything here by that name.\r\n")
      _ ->
        {entity_pid, real_entity_name, _} = hd(entities_with_name)

        if Fluxspace.Lib.Player.is_player?(entity_pid) do
          Attributes.Clientable.send_message(player_pid, "You whisper to #{real_entity_name}, \"#{message}\"\r\n")
          Attributes.Clientable.send_message(entity_pid, "#{calling_name} whispers to you, \"#{message}\"\r\n")
        else
          Attributes.Clientable.send_message(player_pid, "You attempt to whisper to a #{real_entity_name}.. but it doesn't respond.\r\n")
        end
    end
  end

  def spawn(_, %{"name" => name, "description" => description}, _, player_pid) do
    calling_name = Attributes.Appearance.get_name(player_pid)
    room_pid = ClientGroup.get_room()

    {:ok, _, item} = Fluxspace.Entity.start_plain()

    Attributes.Appearance.register(item,
      %{
        name: name,
        short_description: description,
        long_description: description
      }
    )

    proper_name = Fluxspace.Determiners.determine(name)

    Fluxspace.Lib.Room.add_entity(room_pid, item)
    Attributes.Clientable.send_message(player_pid, "You spawn in #{proper_name} from thin air.\r\n")
    Attributes.Inventory.notify_except(room_pid, player_pid, {:send_message, "With a wave of their fingers, #{calling_name} spawns in a #{proper_name} from thin air.\r\n"})
  end

  def noop(_, _, _, player_pid) do
    Attributes.Clientable.send_message(player_pid, "I'm sorry, what?\r\n")
  end
end
