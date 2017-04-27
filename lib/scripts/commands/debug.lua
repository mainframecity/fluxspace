function debug(args, player_pid, room_pid)
  local entities = fluxspace.get_entities(room_pid)
  fluxspace.inspect(entities)
end

fluxspace.add_command("debug", "(.*?)", "debug")
