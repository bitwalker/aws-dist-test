use Mix.Config

config :web, ExampleWeb.Endpoint,
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  version: Application.spec(:web, :vsn)

config :logger,
  level: :info,
  handle_sasl_reports: true,
  handle_otp_reports: true

