defmodule Todo.CacheTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, cache} = Todo.Cache.start()

    {:ok, cache: cache}
  end

  test "server_process", %{cache: cache} do
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "to-do operations", %{cache: cache} do
    alice = Todo.Cache.server_process(cache, "alice")
    Todo.Server.add_entry(alice, %{date: ~D[2023-12-19], title: "Dentist"})

    entries = Todo.Server.entries(alice, ~D[2023-12-19])
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries
  end
end
