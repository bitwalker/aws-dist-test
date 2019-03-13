defmodule Services.Registry do
  @moduledoc """
  This module provides an API for distributed service discovery
  """

  # Proxy to the supervisor
  defdelegate start_link(opts \\ []), to: __MODULE__.Supervisor
  defdelegate child_spec(args), to: __MODULE__.Supervisor

  @doc """
  Add a service to the registry.
  """
  @spec add(type :: term, pid) :: {:ok, String.t}
  defdelegate add(type, pid), to: __MODULE__.Tracker

  @doc """
  Remove a service from the registry.
  """
  @spec remove(type :: term, pid) :: {:ok, String.t}
  defdelegate remove(type, pid), to: __MODULE__.Tracker

  @doc """
  List all of the services for a particular type.
  """
  @spec list(type :: term) :: [{pid, map}]
  defdelegate list(type), to: __MODULE__.Tracker

  @doc """
  Find a service to use for a particular `key`
  """
  @spec find(type :: term) :: {:ok, node, pid}
  @spec find(type :: term, key :: term) :: {:ok, node, pid}
  defdelegate find(type, key \\ self()), to: __MODULE__.Tracker

  @doc """
  Cast a message to an instance of the service with the given type and key
  """
  @spec cast(type :: term, key :: term, msg ::term) :: :ok | {:error, :service_unavailable}
  def cast(type, key, msg) do
    case find(type, key) do
      {:ok, _node, pid} ->
        GenServer.cast(pid, msg)

      _ ->
        {:error, :service_unavailable}
    end
  end

  @doc """
  Call an instance of the service with the given type and key
  """
  @spec call(type :: term, key :: term, msg :: term) :: term | {:error, :service_unavailable}
  @spec call(type :: term, key :: term, msg :: term, timeout) :: term | {:error, :service_unavailable}
  def call(type, key, params, timeout \\ 5000) do
    case find(type, key) do
      {:ok, _node, pid} ->
        GenServer.call(pid, params, timeout)

      _ ->
        {:error, :service_unavailable}
    end
  end
end
