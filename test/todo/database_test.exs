defmodule Todo.DatabaseTest do
  require GenServer
  use ExUnit.Case

  @moduletag :tmp_dir

  setup %{tmp_dir: tmp_dir} do
    start_supervised!(Todo.ProcessRegistry)
    start_supervised!({Todo.Database, tmp_dir})

    :ok
  end

  test "get nonexsistent" do
    assert Todo.Database.get("some name") == nil
  end

  @tag :tmp_dir
  test "persist list", %{tmp_dir: tmp_dir} do
    Todo.Database.store("bob", :my_secret_value)
    assert :my_secret_value = Todo.Database.get("bob")

    stop_supervised!(Todo.Database)

    start_supervised!({Todo.Database, tmp_dir})
    assert :my_secret_value = Todo.Database.get("bob")
  end
end
