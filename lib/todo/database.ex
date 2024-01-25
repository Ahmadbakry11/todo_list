defmodule Todo.Database do

  alias Todo.Databaseworker

  @db_folder "todo_database"
  @db_workers 3

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,

      [
        name: {:local, __MODULE__},
        worker_module: Databaseworker,
        size: @db_workers
      ],

      [@db_folder]
    )
  end

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Databaseworker.store(worker_pid, key, data)
      end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Databaseworker.get(worker_pid, key)
      end
    )
  end
end
