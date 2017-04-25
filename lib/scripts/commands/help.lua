function help(args, player_pid)
  message = [[
  ------------------------------
  Welcome to Fluxspace.

  [DEBUG]
  spawn <name>, <description> - Debug command to spawn an entity in the current room.

  [NORMAL]
  help - Display this message.
  say <message> - Say a message.
  look - Look around the room.
  look at <name> - Look at a thing.
  whisper to <name> <message> - Whisper a message to someone.
  logout - Logs you out.
  ------------------------------
  ]]

  fluxspace.send_message(player_pid, message)
end

fluxspace.add_command("help", "(.*?)", "help")
