use Mix.Config

config :engine, Engine.Repo,
  adapter: Ecto.Adapters.Postgres

config :logger,
  level: :info,
  handle_sasl_reports: true,
  handle_otp_reports: true
