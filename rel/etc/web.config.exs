use Mix.Config

# Application name
app = System.get_env("APPLICATION_NAME")
env = System.get_env("ENVIRONMENT_NAME")
region = System.get_env("AWS_REGION")

# Locate awscli
aws = System.find_executable("aws")

cond do
  is_nil(app) ->
    raise "APPLICATION_NAME is unset!"
  is_nil(env) ->
    raise "ENVIRONMENT_NAME is unset!"
  is_nil(aws) ->
    raise "Unable to find `aws` executable!"
  :else ->
    :ok
end

# Set configuration for Phoenix endpoint
config :web, ExampleWeb.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  root: ".",
  secret_key_base: "u1QXlca4XEZKb1o3HL/aUlznI1qstCNAQ6yme/lFbFIs0Iqiq/annZ+Ty8JyUCDc",
  server: true

config :services, Services.Database, Engine.Database
config :services, Services.Todos, Engine.Todo

config :services, Services.Cluster,
  topologies: [
    ec2: [
      strategy: ClusterEC2.Strategy.Tags,
      config: [
        ec2_tagname: "distribution-group",
        ec2_tagvalue: "#{app}-#{env}",
        app_prefix: "distillery_example"
      ]
    ]
  ]

config :services, Services.Registry,
  log_level: :warn,
  broadcast_period: 10,
  max_silent_periods: 2,
  pool_size: 1,
  name: Services.Registry.PubSub
