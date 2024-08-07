defmodule Todo.SystemTest do
  use ExUnit.Case

  test "" do
    start_link_supervised!(Todo.System)

    assert Process.whereis(Todo.ProcessRegistry) != nil
    assert Process.whereis(Todo.Database) != nil
    assert Process.whereis(Todo.Cache) != nil
  end
end
