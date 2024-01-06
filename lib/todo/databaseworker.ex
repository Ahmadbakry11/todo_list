defmodule Todo.Databaseworker do
  use GenServer

  alias Todo.ProcessRegistry

  def start_link({worker_id, db_folder}) do
    IO.puts("Starting Database Worker #{worker_id}.....")
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))
  end

  def init(db_folder) do
    {:ok, db_folder}
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  def handle_cast({:store, key, data}, state) do
    file_name(key, state)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  def handle_call({:get, key}, _, state) do
    todo_list  = case File.read(file_name(key, state)) do
      {:error, :enoent} -> nil
      {:ok, content} -> :erlang.binary_to_term(content)
    end

    {:reply, todo_list, state}
  end

  defp file_name(key, db_folder) do
    Path.join(db_folder, to_string(key))
  end

  defp via_tuple(id) do
    ProcessRegistry.via_tuple({__MODULE__, id})
  end
end
