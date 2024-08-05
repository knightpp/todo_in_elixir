defmodule Todo.DatabaseTest do
  require GenServer
  use ExUnit.Case

  setup do
    if GenServer.whereis(Todo.Database) != nil do
      GenServer.stop(Todo.Database)
    end

    :ok
  end

  @tag :tmp_dir
  test "get nonexsistent", %{tmp_dir: tmp_dir} do
    {:ok, pid} = Todo.Database.start_link(tmp_dir)

    assert Todo.Database.get("some name") == nil

    GenServer.stop(pid)
  end

  @tag :tmp_dir
  test "persist list", %{tmp_dir: tmp_dir} do
    {:ok, pid} = Todo.Database.start_link(tmp_dir)
    Todo.Database.store("bob", :my_secret_value)
    assert :my_secret_value = Todo.Database.get("bob")

    GenServer.stop(pid)

    {:ok, _} = Todo.Database.start_link(tmp_dir)
    assert :my_secret_value = Todo.Database.get("bob")
  end
end
