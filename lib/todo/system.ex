defmodule Todo.System do
  use Supervisor

  def start() do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    Supervisor.init(
      [
        Todo.ProcessRegisty,
        Todo.Database,
        Todo.Cache
      ],
      strategy: :one_for_one
    )
  end
end

# Run process
# Todo.System.start()
# :erlang.system_info(:process_count)  #70
#
# cache_pid = Process.whereis(Todo.Cache)
# Process.exit(cache_pid, :kill)
# :erlang.system_info(:process_count)  #70
#
# # Restart again:
# for _ <- 1..4 do
#   Process.exit(Process.whereis(Todo.Cache), :kill)
#   Process.sleep(200)
# end
#
# This will terminate the Supervisor process and all its children
# because it exceeded the limit for restart(3 times per 5 seconds)
