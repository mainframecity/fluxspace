defmodule Fluxspace do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    Fluxspace.File.start

    base_children = [
      worker(Fluxspace.Entrypoints.TCP, [[], []])
    ]

    config = Application.get_env(:fluxspace, Fluxspace) || []

    children = Keyword.get(config, :daemons, []) |> Enum.reduce(base_children, fn(daemon, acc) ->
      [
        worker(daemon, [[], [name: daemon]]) | acc
      ]
    end)

    opts = [strategy: :one_for_one, name: Fluxspace.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
