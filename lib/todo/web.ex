defmodule Todo.Web do
  use Plug.Router
  require Logger

  plug Plug.Logger, log: :debug
  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch

  def child_spec(_) do
    IO.puts "Starting the web server....."
    Plug.Cowboy.child_spec(
      scheme: :http,
      options: [port: Application.get_env(:todo, :port)],
      plug: __MODULE__
    )
  end

  get "/ping" do
    conn
    |> send_resp(200, "pong!")
  end

  post "/todos/:list_name" do
    case conn.body_params do
      %{"entry" => %{"date" => date, "task" => task}} ->
        todo_entry = Todo.Entry.new(date, task)

        list_name
        |> Todo.Cache.server_process()
        |> Todo.Server.add_entry(todo_entry)

        send_resp(conn, 200, "ok")

      _ -> send_resp(conn, 422, bad_entry())
    end
  end

  get "/todos/:name" do
    todos =
    name
    |> Todo.Cache.server_process()
    |> Todo.Server.entries()
    |> Todo.List.todos_list()

    send_resp(conn, 200, process_response(todos))
  end

  match _ do
    conn
    |> send_resp(404, "resource not found")
  end

  defp process_response(res) do
    Jason.encode!(res)
  end

  defp bad_entry() do
    Jason.encode!(%{"error" => "request body is missing params"})
  end
end
