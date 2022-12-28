defmodule Todo.Cache do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, cache) do
    case Map.fetch(cache, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, cache}
      :error ->
        {:ok, new_server} = Todo.Server.start()
        {:reply, new_server, Map.put(cache, todo_list_name, new_server)}
    end
  end
end
