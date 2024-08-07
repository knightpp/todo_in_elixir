defmodule Todo.ServerTest do
  use ExUnit.Case

  @moduletag :tmp_dir

  setup %{tmp_dir: tmp_dir} do
    start_link_supervised!(Todo.ProcessRegistry)
    start_link_supervised!({Todo.Database, tmp_dir})
    server = start_link_supervised!({Todo.Server, "bob"})
    %{server: server}
  end

  test "remove unexsiting entry", %{server: server} do
    assert :ok = Todo.Server.delete_entry(server, -1)
  end

  test "remove existing entry", %{server: server} do
    date = ~D[2023-01-01]

    assert :ok = Todo.Server.add_entry(server, %{date: date, title: "hello world"})
    assert :ok = Todo.Server.delete_entry(server, 1)
    assert [] = Todo.Server.entries(server, date)
  end
end
