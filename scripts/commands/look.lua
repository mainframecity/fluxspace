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

function look_at(args, player_pid, room_pid)
  local search_name = args["name"]
  local entities = fluxspace.get_entities(room_pid)
  local entity_names = {}

  for _, entity_pid in ipairs(entities) do
    local name = fluxspace.get_name(entity_pid)
    local real_name = ""

    if fluxspace.is_player(entity_pid) then
      real_name = name
    else
      real_name = fluxspace.add_determiner(name)
    end

    local jaro_distance = fluxspace.jaro_distance(real_name, search_name)

    table.insert(entity_names, {entity_pid, real_name, jaro_distance})
  end

  table.sort(entity_names, function(a, b)
    return a[3] > b[3]
  end)

  local entity = table.remove(entity_names, 1)

  if entity and entity[3] > 0.9 then
    local entity_description = fluxspace.get_long_description(entity[1])
    fluxspace.broadcast_message(room_pid, name .. " looks at " .. entity[2])
    fluxspace.send_message(player_pid, entity_description)
  else
    fluxspace.send_message(player_pid, "There's nothing around here with that name.")
  end
end

fluxspace.add_command("look", "at (?<name>.+)", "look_at")
fluxspace.add_command("look", "(.*?)", "look")
