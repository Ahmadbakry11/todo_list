defmodule Todo.Database do

  alias Todo.Databaseworker

  @db_folder "todo_database"
  @db_workers 3

  def start_link() do
    IO.puts("Starting Todo Database.....")
    File.mkdir_p!(@db_folder)
    children = Enum.map(1..@db_workers, &worker_spec(&1))
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def worker_spec(id) do
    default_worker_spec = {Databaseworker, {id, @db_folder}}
    Supervisor.child_spec(default_worker_spec, id: id)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def get_worker(key) do
    :erlang.phash2(key, @db_workers) + 1
  end

  def store(key, data) do
    key
    |> get_worker()
    |> Databaseworker.store(key, data)
  end

  def get(key) do
    key
    |> get_worker()
    |> Databaseworker.get(key)
  end
end
