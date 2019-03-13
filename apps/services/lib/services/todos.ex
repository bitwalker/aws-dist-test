defmodule Services.Todos do
  @moduledoc "This module defines the contract for interacting with TODOs"

  alias Services.Service

  defmacro __using__(_) do
    quote do
      use Services.Service, type: unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
    end
  end

  @type t :: %{
    title: String.t,
    completed: boolean,
    updated_at: NaiveDateTime.t,
    created_at: NaiveDateTime.t,
  }

  @callback create(Ecto.Changeset.t) :: {:ok, t} | {:error, [term]}
  @callback update(map) :: {:ok, t} | {:error, [term]}
  @callback delete(String.t) :: :ok | {:error, [term]}
  @callback delete_all() :: :ok | {:error, String.t}
  @callback all() :: {:ok, [t]} | {:error, String.t}
  @callback changeset(map) :: Ecto.Changeset.t
  @callback changeset(t, map) :: Ecto.Changeset.t

  @doc "Create a TODO from an Ecto changeset"
  def create(changeset) do
    Service.call(__MODULE__, :create, [changeset])
  end

  @doc "Update a TODO given a map of parameters"
  def update(params) do
    Service.call(__MODULE__, :update, [params])
  end

  @doc "Delete a TODO by ID"
  def delete(id) do
    Service.call(__MODULE__, :delete, [id])
  end

  @doc "Delete all TODOs"
  def delete_all() do
    Service.call(__MODULE__, :delete_all, [])
  end

  @doc "Return a list of all TODOs"
  def all() do
    Service.call(__MODULE__, :all, [])
  end

  @doc "Generate an Ecto changeset from a TODO and a set of changes"
  def changeset(changes) do
    Service.call(__MODULE__, :changeset, [changes])
  end

  @doc "Generate an Ecto changeset from a TODO and a set of changes"
  def changeset(t, changes) do
    Service.call(__MODULE__, :changeset, [t, changes])
  end

  @doc "Starts the backing implementation, if needed"
  def start_link(args) when is_list(args) do
    impl().start_link(args)
  end

  @doc false
  def impl do
    mod = Application.fetch_env!(:services, __MODULE__)
    unless is_atom(mod) do
      raise "Invalid service type for #{__MODULE__}, expected module, got: #{inspect mod}"
    end
    mod
  end
end
