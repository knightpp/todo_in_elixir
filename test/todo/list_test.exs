defmodule Todo.ListTest do
  use ExUnit.Case

  @entry1 %Todo.List.Entry{date: ~D[2022-01-01], title: "entry 1"}
  @entry2 %Todo.List.Entry{date: ~D[2022-02-01], title: "entry 2"}

  test "add_entry" do
    list = Todo.List.new()

    entry = %Todo.List.Entry{
      date: DateTime.utc_now() |> DateTime.to_date(),
      title: "adding test entry"
    }

    list = Todo.List.add_entry(list, entry)

    entry = %{entry | id: 1}
    assert [^entry] = Todo.List.entries(list, entry.date)
  end

  test "multiple entries per day" do
    list = Todo.List.new([@entry1, @entry1])

    entry1 = %{@entry1 | id: 1}
    entry2 = %{@entry1 | id: 2}

    assert [^entry1, ^entry2] = Todo.List.entries(list, entry1.date)
  end

  test "delete entry" do
    list = Todo.List.new([@entry1, @entry2])
    list = Todo.List.delete_entry(list, 1)
    entry = %{@entry2 | id: 2}
    assert [^entry] = Todo.List.entries(list, @entry2.date)
  end

  test "update entry" do
    list = Todo.List.new([@entry1, @entry2])

    list =
      Todo.List.update_entry(list, 1, fn entry ->
        %{entry | title: "changed"}
      end)

    entry1 = %{@entry1 | id: 1, title: "changed"}
    entry2 = %{@entry2 | id: 2}

    assert [^entry1] = Todo.List.entries(list, @entry1.date)
    assert [^entry2] = Todo.List.entries(list, @entry2.date)
  end

  test "update nonexistent entry" do
    list = Todo.List.new([@entry1, @entry2])
    list =
      Todo.List.update_entry(list, -1, fn entry ->
        %{entry | title: "changed"}
      end)

    entry1 = %{@entry1 | id: 1}
    entry2 = %{@entry2 | id: 2}

    assert [^entry1] = Todo.List.entries(list, @entry1.date)
    assert [^entry2] = Todo.List.entries(list, @entry2.date)
  end
end
