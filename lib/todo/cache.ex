defmodule Todo.Cache do
  use GenServer
  require Logger

  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec server_process(String.t()) :: pid()
  def server_process(list_name) do
    GenServer.call(__MODULE__, {:server_process, list_name})
  end

  @impl GenServer
  def init(_) do
    Logger.info("starting #{__MODULE__}")
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
