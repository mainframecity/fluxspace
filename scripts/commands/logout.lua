function logout(args, player_pid, room_pid)
  local formatted_message = name .. " logged out."

  fluxspace.broadcast_message(room_pid, formatted_message)
  fluxspace.send_message(player_pid, "Good-bye.")
  fluxspace.kill(player_pid)
end

fluxspace.add_command("logout", "(.*?)", "logout")
