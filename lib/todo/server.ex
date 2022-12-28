defmodule Todo.Server do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def entries(todo_server) do
    GenServer.call(todo_server, {:entries})
  end

  def update_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:update_entry, new_entry})
  end

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete_entry, entry_id})
  end

  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end

  @impl GenServer
  def handle_cast({:update_entry, new_entry}, todo_list) do
    {:noreply, Todo.List.update_entry(todo_list, new_entry)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, Todo.List.delete_entry(todo_list, entry_id)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end

  @impl GenServer
  def handle_call({:entries}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list), todo_list}
  end
end

# Run and Test
# Todo.Server.start()
# Todo.Server.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
# Todo.Server.add_entry(%{date: ~D[2018-12-20], title: "Shopping"})
# Todo.Server.add_entry(%{date: ~D[2018-12-19], title: "Movies"})
# #
# Todo.Server.update_entry(%{id: 1, date: ~D[2018-12-19], title: "Buy Coffee"})
# Todo.Server.delete_entry(3)
# Todo.Server.entries(~D[2018-12-19])
# Todo.Server.entries()
