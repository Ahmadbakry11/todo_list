defmodule Todo.Database do
  use GenServer

  @db_folder "./persisted_data"

  def start_link(_) do
    IO.puts "Starting the todo Database"
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, start_workers()}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers) do
    {:reply, Map.get(workers, :erlang.phash2(key, 3)), workers}
  end

  defp start_workers() do
    for i <- (0..2), into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder)
      {i, pid}
    end
  end
end
