defmodule Services.Registry.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(opts) when is_list(opts) do
    Supervisor.start_link(__MODULE__, [opts], name: __MODULE__)
  end

  def init([opts]) do
    {pubsub, registry} = Keyword.split(opts, [:pool_size])

    registry = Keyword.put(registry, :name, Services.Registry)

    children = [
      {Phoenix.PubSub.PG2, [Services.Registry.PubSub, pubsub]},
      {Services.Registry.Tracker, [registry]},
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
