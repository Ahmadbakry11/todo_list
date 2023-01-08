defmodule Todo.Cache do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(list_name) do
    GenServer.call(__MODULE__, {:server_process, list_name})
  end

  @impl GenServer
  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, todo_server} = Todo.Server.start(list_name)
        {
          :reply,
          todo_server,
          Map.put(todo_servers, list_name, todo_server)
        }
    end
  end
end
