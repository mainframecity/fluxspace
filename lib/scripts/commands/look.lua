function look(args, player_pid, room_pid)
  local entities = fluxspace.get_entities(room_pid)
  local entity_names = {}

  local room_description = fluxspace.get_long_description(room_pid)

  for k, entity_pid in ipairs(entities) do
    local name = fluxspace.get_name(entity_pid)
    local real_name = ""

    if fluxspace.is_player(entity_pid) then
      real_name = name
    else
      real_name = fluxspace.add_determiner(name)
    end

    table.insert(entity_names, real_name)
  end

  local flattened_entities = table.concat(entity_names, ", ")
  local message = "" .. room_description .. " It contains: " .. flattened_entities

  fluxspace.broadcast_message(room_pid, name .. " looks around the room.")
  fluxspace.send_message(player_pid, message)
end

fluxspace.add_command("look", "(.*?)", "look")
