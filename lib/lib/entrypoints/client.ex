defmodule Fluxspace.Entrypoints.Client do
  defstruct [
    player_uuid: "",
    player_pid: nil,
    entrypoint_module: Fluxspace.Entrypoints.Dummy,
    socket: nil,
    socket_group: nil,
    halted: false,
    initialized: false
  ]
end
