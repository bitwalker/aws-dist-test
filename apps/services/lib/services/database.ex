defmodule Services.Database do
  @moduledoc "This module defines the contract for the database service"

  alias Services.Service

  defmacro __using__(_) do
    quote do
      use Services.Service, type: unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
    end
  end

  @callback available?() :: boolean

  @doc "Answers the question: is the database available?"
  def available?() do
    case Service.call(__MODULE__, :available?, []) do
      {:error, :service_unavailable} ->
        false

      result ->
        result
    end
  end

  @doc "Starts the backing implementation, if needed"
  def start_link(args) when is_list(args) do
    impl().start_link(args)
  end

  @doc false
  def child_spec(args) do
    impl().child_spec(args)
  end

  @doc false
  def impl() do
    mod = Application.fetch_env!(:services, __MODULE__)
    unless is_atom(mod) do
      raise "Invalid service type for #{__MODULE__}, expected module, got: #{inspect mod}"
    end
    mod
  end
end
