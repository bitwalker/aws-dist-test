defmodule Services.Service do
  @moduledoc "Describes the behaviour for service implementations"
  alias Services.Registry

  @type state :: term

  @callback start_link(args :: [term]) :: {:ok, pid} | :ignore | {:error, term}
  @callback handle_service_call(msg :: term, from :: {reference, pid}, state) ::
    {:reply, term, state}
    | {:stop, reason :: term, state}

  @optional_callbacks [handle_service_call: 3]

  defmacro __using__(opts) when is_list(opts) do
    service_type = Keyword.fetch(opts, :type)
    quote do
      @behaviour unquote(__MODULE__)
      use GenServer

      @doc false
      def child_spec(args) do
        %{id: __MODULE__,
          type: :worker,
          start: {__MODULE__, :start_link, [args]}}
      end

      def start_link(args) do
        GenServer.start_link(__MODULE__, [args], name: __MODULE__)
      end

      @doc false
      def init(_) do
        {:ok, _} = Services.Registry.add(unquote(service_type), self())
        {:ok, nil}
      end

      @doc false
      def handle_call({:request, fun, args}, _from, state) do
        {:reply, apply(__MODULE__, fun, args), state}
      rescue
        ex ->
          {:reply, {unquote(service_type), :exception, ex, __STACKTRACE__}, state}
      catch
        type, reason ->
          {:reply, {unquote(service_type), type, reason}, state}
      end
      def handle_call(call, from, state) do
        apply(__MODULE__, :handle_service_call, [call, from, state])
      end

      defoverridable [
        child_spec: 1,
        start_link: 1,
        init: 1,
      ]
    end
  end

  @doc """
  Calls the given service using the provided function and argument list.

  If the service is unavailable, `{:error, :service_unavailable}` is returned.
  """
  @spec call(module, atom, [term]) :: term | {:error, :service_unavailable}
  def call(service_type, function, args) do
    case Registry.find(service_type, self()) do
      {:ok, host, _pid} when host == node() ->
        # Invoke directly since we're on the same node
        apply(service_type.impl(), function, args)

      {:ok, _host, pid} ->
        # Proxy call through remote service
        case GenServer.call(pid, {function, args}, :infinity) do
          {^service_type, :exception, ex, trace} ->
            # Reraise original exception, preserving the stack trace
            reraise ex, trace

          {^service_type, type, reason} ->
            # Reraise original error, the reason typically contains the trace
            apply(:erlang, type, [reason])

          result ->
            # Normal result
            result
        end

      _ ->
        # No service available, or not running distributed
        {:error, :service_unavailable}
    end
  catch
    {:exit, {:noproc, _}} ->
      # Remote service crashed or disconnected while waiting for call to return
      {:error, :service_unavailable}
  end
end
