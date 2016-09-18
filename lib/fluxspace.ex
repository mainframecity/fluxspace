defmodule Fluxspace do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    Fluxspace.File.start

    base_children = [
      supervisor(Fluxspace.Endpoint, [])
    ]

    config = Application.get_env(:fluxspace, Fluxspace.Server) || []

    children = if Keyword.get(config, :disabled, false) do
      base_children
    else
      [worker(Fluxspace.Server, []) | base_children]
    end

    opts = [strategy: :one_for_one, name: Fluxspace.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
