defmodule Todo.ServerTest do
  use ExUnit.Case

  setup do
    server = start_link_supervised!({Todo.Server, "#{__MODULE__}-list"})

    path = Application.fetch_env!(:todo, :db_path)
    on_exit(fn -> File.rm!("#{path}/#{__MODULE__}-list") end)
    %{server: server}
  end

  test "remove unexsiting entry", %{server: server} do
    assert :ok = Todo.Server.delete_entry(server, -1)
  end

  test "remove existing entry", %{server: server} do
    date = ~D[2023-01-01]

    assert :ok = Todo.Server.add_entry(server, %{date: date, title: "hello world"})
    assert [%{date: ^date, title: "hello world", id: 1}] = Todo.Server.entries(server, date)
    assert :ok = Todo.Server.delete_entry(server, 1)
    assert [] = Todo.Server.entries(server, date)
  end
end
