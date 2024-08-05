defmodule Todo.Cache do
  use GenServer

  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(dir) do
    GenServer.start_link(__MODULE__, dir)
  end

  @spec server_process(GenServer.server(), String.t()) :: pid()
  def server_process(server, list_name) do
    GenServer.call(server, {:server_process, list_name})
  end

  @impl GenServer
  def init(dir) do
    Todo.Database.start_link(dir)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, list_name) do
      {:ok, server} ->
        {:reply, server, todo_servers}

      :error ->
        {:ok, new_server} = Todo.Server.start_link(list_name)
        {:reply, new_server, Map.put(todo_servers, list_name, new_server)}
    end
  end
end
