defmodule Todo.Databaseworker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
  end

  @impl GenServer
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    state
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    todo_list  = case File.read(file_name(state, key)) do
      {:error, :enoent} -> nil
      {:ok, content} -> :erlang.binary_to_term(content)
    end

    {:reply, todo_list, state}
  end

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end
end
