defmodule Todo.List do
  defstruct next_id: 1, entries: %{}
  @type t() :: %__MODULE__{next_id: number(), entries: %{number() => Todo.List.Entry.t()}}

  @spec new() :: t()
  def new() do
    %Todo.List{}
  end

  @spec new([Todo.List.Entry]) :: t()
  def new(entries) do
    Enum.reduce(entries, %Todo.List{}, fn entry, acc ->
      add_entry(acc, entry)
    end)
  end

  @spec add_entry(t(), Todo.List.Entry.t()) :: t()
  def add_entry(%Todo.List{next_id: next_id, entries: entries}, entry) do
    entry = Map.put(entry, :id, next_id)
    new_entries = Map.put(entries, entry.id, entry)
    %Todo.List{next_id: next_id + 1, entries: new_entries}
  end

  @spec entries(t(), Date) :: [Todo.List.Entry.t()]
  def entries(list, date) do
    list.entries |> Map.values() |> Enum.filter(fn entry -> entry.date == date end)
  end

  @spec update_entry(t(), number(), (Todo.List.Entry -> Todo.List.Entry)) :: t()
  def update_entry(list, id, updater_fun) do
    case Map.fetch(list.entries, id) do
      :error ->
        list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(list.entries, new_entry.id, new_entry)
        %Todo.List{list | entries: new_entries}
    end
  end

  @spec delete_entry(t(), number()) :: t()
  def delete_entry(list, id) do
    entries = Map.delete(list.entries, id)
    %Todo.List{list | entries: entries}
  end
end

defimpl Collectable, for: Todo.List do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(list, {:cont, entry}) do
    Todo.List.add_entry(list, entry)
  end

  defp into_callback(list, :done), do: list
  defp into_callback(_list, :halt), do: :ok
end

defmodule Todo.List.Entry do
  @enforce_keys [:date, :title]
  defstruct date: nil, title: "", id: nil

  @type t() :: %__MODULE__{date: Date, title: String.t(), id: number()}
end
