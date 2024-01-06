defmodule Todo.Metrics do
  def start() do
    IO.puts("Starting Metrics service.....")
    Task.start_link(&log_metrics/0)
  end

  defp log_metrics() do
    IO.inspect(collect_metrics())
  end

  defp collect_metrics() do
    [
      memory_usgae: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
