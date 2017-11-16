function say(args, player_pid, room_pid)
  local formatted_message = name .. " says, \"" .. args["message"] .. "\"."

  fluxspace.send_message(player_pid, "You say, \"" .. args["message"] .. "\".")
  fluxspace.broadcast_message(room_pid, formatted_message)
end

fluxspace.add_command("say", "(?<message>.+)", "say")
