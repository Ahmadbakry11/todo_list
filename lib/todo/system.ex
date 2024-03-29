defmodule Todo.System do
  def start_link() do
    Supervisor.start_link(
      [
        Todo.ProcessRegistry,
        Todo.Database,
        Todo.Cache,
        Todo.Web
        # Todo.MetricsScheduler
      ],
      strategy: :one_for_one
    )
  end
end
