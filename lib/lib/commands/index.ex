defmodule Fluxspace.Commands.Index do
  use Fluxspace.Commands.Macros

  alias Fluxspace.Entrypoints.ClientGroup
  alias Fluxspace.Lib.Attributes

  commands do
    command "spawn (?<name>.+), (?<description>.+)", &__MODULE__.spawn/4
    command "whisper to (?<subject>[^\s]+) (?<message>.+)", &__MODULE__.whisper_to/4
    command "(.*?)", &__MODULE__.noop/4
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
