# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :fluxspace, Fluxspace.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hQ+uGSrgZ6ONp3y8CMKyeeq8XVs4AisBdcsCSbmj41ZxbJ0/326Bv3ggB4kiRXyk",
  render_errors: [view: Fluxspace.ErrorView, accepts: ~w(json)],
  pubsub: [name: Fluxspace.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
