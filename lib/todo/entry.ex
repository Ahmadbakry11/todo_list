defmodule Todo.Entry do
  alias Todo.Entry

  defstruct id: nil, date: nil, title: nil

  def new(date, title) do
    %Entry{id: nil, date: date, title: title}
  end

  def new(%{date: date, title: title}) do
    %Entry{id: nil, date: date, title: title}
  end
end
