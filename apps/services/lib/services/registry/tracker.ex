defmodule Services.Registry.Tracker do
  # This module provies synchronization of the registry across nodes
  @moduledoc false
  @behaviour Phoenix.Tracker

  @spec add(type :: term, pid) :: {:ok, String.t}
  def add(type, pid) do
    Phoenix.Tracker.track(__MODULE__, pid, type, pid, %{node: node()})
  end

  @spec remove(type :: term, pid) :: {:ok, String.t}
  def remove(type, pid) do
    Phoenix.Tracker.untrack(__MODULE__, pid, type, pid)
  end

  @spec list(type :: term) :: [{pid, map}]
  def list(type) do
    Phoenix.Tracker.list(__MODULE__, type)
  end

  @spec find(type :: term) :: {:ok, node, pid}
  @spec find(type :: term, key :: term) :: {:ok, node, pid}
  def find(type, key \\ self()) do
    with [{_, ring}] <- :ets.lookup(__MODULE__.Types, type),
         {service_node, service_pid} <- HashRing.key_to_node(ring, key) do
      {:ok, service_node, service_pid}
    else
      _ ->
        {:error, :service_unavailable}
    end
  end

  @doc false
  def child_spec(args) do
    %{id: __MODULE__,
      start: {__MODULE__, :start_link, args},
      type: :worker}
  end

  @doc false
  def start_link(opts \\ []) when is_list(opts) do
    full_opts =
      Keyword.merge(opts, [name: __MODULE__, pubsub_server: Services.Registry.PubSub])

    Phoenix.Tracker.start_link(__MODULE__, full_opts, full_opts)
  end

  @doc false
  def init(opts) when is_list(opts) do
    :ets.new(__MODULE__.Types, [:public, :set, :named_table])
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server, hash_rings: %{}}}
  end

  @doc false
  def handle_diff(diff, %{hash_rings: hash_rings} = state) do
    hash_rings =
      Enum.reduce(diff, hash_rings, fn {type, _} = event, hash_rings ->
        hash_ring =
          hash_rings
          |> Map.get(type, HashRing.new())
          |> remove_leaves(event, state)
          |> add_joins(event, state)

        :ets.insert(__MODULE__.Types, {type, hash_ring})
        Map.put(hash_rings, type, hash_ring)
      end)

    {:ok, %{state | hash_rings: hash_rings}}
  end

  defp remove_leaves(hash_ring, {type, {joins, leaves}}, state) do
    Enum.reduce(leaves, hash_ring, fn {pid, meta}, acc ->
      service_info = {meta.node, pid}

      has_joins =
        Enum.any?(joins, fn {joined, _meta_state} ->
          joined == pid
        end)

      Phoenix.PubSub.direct_broadcast(node(), state.pubsub_server, type, {:leave, pid, meta})

      if has_joins do
        acc
      else
        HashRing.remove_node(acc, service_info)
      end
    end)
  end

  defp add_joins(hash_ring, {type, {joins, _leaves}}, state) do
    Enum.reduce(joins, hash_ring, fn {pid, meta}, acc ->
      service_info = {meta.node, pid}
      Phoenix.PubSub.direct_broadcast(node(), state.pubsub_server, type, {:join, pid, meta})

      HashRing.add_node(acc, service_info)
    end)
  end
end
