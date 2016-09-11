defmodule Fluxspace do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Fluxspace.Endpoint, []),

      supervisor(Fluxspace.InventorySupervisor, [], name: Fluxspace.InventorySupervisor),
      supervisor(Fluxspace.RegionSupervisor, [], name: Fluxspace.RegionSupervisor),
      worker(Fluxspace.PlayerRegistry, [], name: Fluxspace.PlayerRegistry)
    ]

    opts = [strategy: :one_for_one, name: Fluxspace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Fluxspace.Endpoint.config_change(changed, removed)
    :ok
  end
end
