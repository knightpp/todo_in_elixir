defmodule Todo.DatabaseTest do
  require GenServer
  use ExUnit.Case

  test "get nonexsistent" do
    assert Todo.Database.get("some name") == nil
  end

  test "persist list store" do
    Todo.Database.store("bob", :my_secret_value)
    assert :my_secret_value = Todo.Database.get("bob")
  end

  test "persist list get" do
    assert :my_secret_value = Todo.Database.get("bob")
  end
end
