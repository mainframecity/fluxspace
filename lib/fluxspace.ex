defmodule Fluxspace do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    Fluxspace.File.start

    children = [
      supervisor(Fluxspace.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: Fluxspace.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
