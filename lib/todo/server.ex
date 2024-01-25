defmodule Todo.Server do
  use GenServer, restart: :temporary

  alias Todo.List
  alias Todo.Entry
  alias Todo.Database
  alias Todo.ProcessRegistry

  @expiry_idle_timeout :timer.seconds(100000)

  def start_link(todo_list_name) do
    IO.puts("Starting Todo Server for #{todo_list_name}.....")
    GenServer.start_link(__MODULE__, todo_list_name, name: via_tuple(todo_list_name))
  end

  def init(name) do
    todo_list = Database.get(name) || List.new(name)
    {:ok, todo_list}
    # send(self(), {:init, name})
    # {:ok, nil, @expiry_idle_timeout}
  end

  def add_entry(todo_pid, entry) do
    GenServer.cast(todo_pid, {:post, entry})
  end

  def add_entries(todo_pid, entries) do
    GenServer.cast(todo_pid, {:post, entries})
  end

  def update_entry(todo_pid, entry_id, updater) do
    GenServer.cast(todo_pid, {:update, entry_id, updater})
  end

  def delete_entry(todo_pid, entry_id) do
    GenServer.cast(todo_pid, {:delete, entry_id})
  end

  def entries(todo_pid) do
    GenServer.call(todo_pid, {:get})
  end

  def entries(todo_pid, date) do
    GenServer.call(todo_pid, {:get, date})
  end

  def handle_info({:init, name}, _) do
    todo_list = Database.get(name) || List.new(name)
    {:noreply, todo_list, @expiry_idle_timeout}
  end

  def handle_info(:timeout, todo_list) do
    IO.puts("Stopping the todo server for #{todo_list.name}")
    {:stop, :normal, todo_list}
  end

  def handle_cast({:post, %Entry{} = entry}, todo_list) do
    new_todo_list = List.add_entry(todo_list, entry)
    Database.store(new_todo_list.name, new_todo_list)

    {:noreply, new_todo_list, @expiry_idle_timeout}
  end

  def handle_cast({:post, [_ | _] = entries}, todo_list) do
    new_todo_list = List.add_entries(todo_list, entries)
    Database.store(new_todo_list.name, new_todo_list)

    {:noreply,new_todo_list, @expiry_idle_timeout}
  end

  def handle_cast({:update, entry_id, updater}, todo_list) do
    new_todo_list = List.update_entry(todo_list, entry_id, updater)
    Database.store(new_todo_list.name, new_todo_list)

    {:noreply, new_todo_list, @expiry_idle_timeout}
  end

  def handle_cast({:delete, entry_id}, todo_list) do
    new_todo_list = List.delete_entry(todo_list, entry_id)
    Database.store(new_todo_list.name, new_todo_list)

    {:noreply, new_todo_list, @expiry_idle_timeout}
  end

  def handle_call({:get}, _, todo_list) do
    {:reply, List.entries(todo_list), todo_list, @expiry_idle_timeout}
  end

  def handle_call({:get, date}, _, todo_list) do
    {:reply, List.entries(todo_list, date), todo_list, @expiry_idle_timeout}
  end

  defp via_tuple(name) do
    ProcessRegistry.via_tuple({__MODULE__, name})
  end
end

# e1 = Todo.Entry.new(~D[2020-11-12], "Dentist")
# e2 = Todo.Entry.new(~D[2020-11-12], "shopping")
# e3 = Todo.Entry.new(~D[2020-11-15], "Gym")

# entries = [
#   %{date: ~D[2020-11-13], title: "cooking food"},
#   %{date: ~D[2020-11-14], title: "biking"},
#   %{date: ~D[2020-11-17], title: "airport"}
# ]

# updater = fn x -> %Todo.Entry{id: x.id, date: x.date, title: "reading"} end

# Todo.Server.start()
# Todo.Server.add_entry(e1)
# Todo.Server.add_entry(e2)
# Todo.Server.add_entry(e3)


# Todo.Server.add_entries(entries)

# Todo.Server.update_entry(1, updater)

# Todo.Server.delete_entry(4)
