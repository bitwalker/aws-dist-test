defmodule Engine.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Services.Database, [[]]},
      {Services.Todos, [[]]},
    ]

    opts = [strategy: :one_for_one, name: Engine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
