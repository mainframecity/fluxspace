# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :fluxspace, Fluxspace,
  daemons: [
#   Fluxspace.Lib.Daemons.CLI,
    Fluxspace.Lib.Daemons.Region
  ]

config :fluxspace, ecto_repos: [Fluxspace.Repo]

config :fluxspace, Fluxspace.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "fluxspace",
  username: "postgres",
  password: "postgres",
  port: "5432"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
