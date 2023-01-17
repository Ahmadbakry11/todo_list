defmodule Todo.Database do
  @db_folder "./persisted_data"
  @pool_size 3

  def start_link(_) do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec(&1))
    Supervisor.start_link(children, strategy: :one_for_one)
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
    :erlang.phash2(key, @pool_size) + 1
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [nil]},
      type: :supervisor
    }
  end

  defp worker_spec(worker_id) do
    default_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_spec, id: worker_id)
  end
end
