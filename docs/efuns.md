### Fluxspace efuns

*external functions*, or *efuns* for short, are functions injected into the global Lua state
to allow scripts to hook into the rest of the MUD engine.

### fluxspace

> `fluxspace.send_message(pid, message)`

Sends a client-bound message to the given entity pid.

Example:

```
fluxspace.send_message(player_pid, "You enter the room.")
```

> `fluxspace.add_command(command_name, regex, function_name)`

Adds a new command accessible by the player.

Example:

```
function moo(args, player_pid)
  fluxspace.send_message(player_pid, "MOOOOOOOO!")
end

fluxspace.add_command("moo", "(.*?)", "moo")
```
