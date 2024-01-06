defmodule Todo.MetricsScheduler do
  use Task

  def start_link(_) do
    IO.puts("Starting the Metrics scheduling service.....")
    Task.start_link(&run/0)
  end

  defp run() do
    Process.sleep(10000)
    Todo.Metrics.start()
    run()
  end
end
