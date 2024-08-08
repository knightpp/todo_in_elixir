defmodule Todo.SystemTest do
  use ExUnit.Case

  test "" do
    assert Process.whereis(Todo.ProcessRegistry) != nil
    assert Process.whereis(Todo.Database) != nil
    assert Process.whereis(Todo.Cache) != nil
  end
end
