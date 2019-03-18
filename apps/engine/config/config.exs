# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# General application configuration
config :engine,
  ecto_repos: [Engine.Repo]

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

import_config "#{Mix.env}.exs"
