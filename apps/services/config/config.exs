# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

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
  pool_size: 1
