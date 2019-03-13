defmodule ExampleWeb.TodoController do
  use ExampleWeb, :controller

  def index(conn, _params) do
    case Services.Todos.all() do
      {:ok, todos} ->
        render(conn, "index.html", todos: todos)
      {:error, reason} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, reason)
    end
  rescue
    err ->
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(500, Exception.message(err))
  end

  def list(conn, _params) do
    case Services.Todos.all() do
      {:ok, todos} ->
        ok(conn, todos)
      {:error, reason} ->
        error(conn, "#{inspect reason}")
    end
  rescue
    err ->
      error(conn, Exception.message(err))
  end

  def create(conn, params) do
    with changeset = Services.Todos.changeset(params),
         {:ok, created} <- Services.Todos.create(changeset) do
           IO.inspect created, label: :created
      ok(conn, created)
    else
      {:error, reason} ->
        error(conn, "#{inspect reason}")
    end
  rescue
    err ->
      error(conn, Exception.message(err))
  end

  def update(conn, params) do
    case Services.Todos.update(params) do
      {:ok, _} ->
        send_resp(conn, 200, "")
      {:error, reason} ->
        error(conn, "#{inspect reason}")
    end
  rescue
    err ->
      error(conn, Exception.message(err))
  end

  def delete(conn, %{"id" => id}) do
    case Services.Todos.delete(id) do
      :ok ->
        send_resp(conn, 200, "")
      {:error, reason} ->
        error(conn, "#{inspect reason}")
    end
  rescue
    err ->
      error(conn, Exception.message(err))
  end

  def delete_all(conn, _) do
    case Services.Todos.delete_all() do
      :ok ->
        send_resp(conn, 200, "")
      {:error, reason} ->
        error(conn, "#{inspect reason}")
    end
  rescue
    err ->
      error(conn, Exception.message(err))
  end

  defp ok(conn, content) do
    json(conn, content)
  end

  defp error(conn, reason) do
    err = %{message: reason}
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(err))
  end
end
