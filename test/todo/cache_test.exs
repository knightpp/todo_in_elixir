defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "to-do operations" do
    alice = Todo.Cache.server_process("alice")
    date = ~D[2023-12-19]

    Todo.Server.entries(alice, date)
    |> Stream.map(fn %{id: id} -> id end)
    |> Enum.each(&Todo.Server.delete_entry(alice, &1))

    Todo.Server.add_entry(alice, %{date: date, title: "Dentist"})

    entries = Todo.Server.entries(alice, date)
    assert [%{date: ^date, title: "Dentist"}] = entries
  end
end
