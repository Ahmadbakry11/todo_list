defmodule Todo.List do
  alias Todo.List
  alias Todo.Entry

  defstruct auto_id: 1, name: nil, entries: %{}

  def new(name) when is_binary(name) do
    %List{name: name, auto_id: 1}
  end

  def add_entry(todo_list, %Entry{} = entry) do
    new_entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, new_entry)

    %List{todo_list | auto_id: todo_list.auto_id + 1, entries: new_entries}
  end

  def add_entries(todo_list, entries) do
    entries
    |> Enum.map(&Entry.new(&1))
    |> Enum.reduce(todo_list, &add_entry(&2, &1))
  end

  def entries(todo_list) do
    todo_list.entries
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.map(fn {_, v} -> v end)
    |> Enum.filter(&(&1.date == date))
  end

  def update_entry(todo_list, entry_id, updater) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %Entry{id: ^old_entry_id} = updater.(old_entry)
        new_entries = Map.put(todo_list.entries, entry_id, new_entry)
        %List{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %Entry{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, entry_id) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, _} ->
        new_entries = Map.delete(todo_list.entries, entry_id)
        %List{todo_list | entries: new_entries}
    end
  end

  def todos_list(todos) do
    todos
    |> Enum.reduce([], fn {_, x}, acc  -> [%{title: x.title, date: x.date} | acc] end)
  end
end
