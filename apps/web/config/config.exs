# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :web, ExampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WLTAq0m3cyhaqufuub/5RyX8E8/s2UR2P1cVJVWn0d46GixiKO6yaTa6i8B8jbzS",
  render_errors: [view: ExampleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Example.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :phoenix, :json_library, Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :services, Services.Database, Engine.Database
config :services, Services.Todos, Engine.Todo

config :services, Services.Cluster,
  topologies: [
    local: [
      strategy: Cluster.Strategy.Epmd,
      config: [hosts: []]
    ]
  ]

config :services, Services.Registry,
  log_level: :warn,
  broadcast_period: 10,
  max_silent_periods: 2,
  pool_size: 1,
  name: Services.Registry.PubSub

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
