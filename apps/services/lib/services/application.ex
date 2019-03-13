defmodule Services.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:services, Services.Cluster, [])
    registry = Application.get_env(:services, Services.Registry, [])

    # List all child processes to be supervised
    children = [
      {Task.Supervisor, [[name: Services.TaskSupervisor]]},
      {Cluster.Supervisor, [topologies, [name: Services.Cluster]]},
      {Services.Registry, [registry]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: Services.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
