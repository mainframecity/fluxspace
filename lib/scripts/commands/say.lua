function say(args, player_pid, room_pid)
  fluxspace.send_message(player_pid, "You say, \"" .. args["message"] .. "\".")
end

fluxspace.add_command("say", "(?<message>.+)", "say")
