defmodule Todo.Server do
  use GenServer
  require Logger

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name)
  end

  @spec add_entry(GenServer.server(), Todo.List.Entry) :: :ok
  def add_entry(server, entry) do
    GenServer.call(server, {:add_entry, entry})
  end

  @spec entries(GenServer.server(), Date) :: [Todo.List.Entry.t()]
  def entries(server, date) do
    GenServer.call(server, {:entries, date})
  end

  @spec delete_entry(GenServer.server(), number()) :: :ok
  def delete_entry(server, id) do
    GenServer.call(server, {:delete_entry, id})
  end

  @impl GenServer
  def init(name) do
    Logger.info("starting #{__MODULE__}")
    {:ok, {name, nil}, {:continue, :init}}
  end

  @impl GenServer
  def handle_call({:add_entry, entry}, _from, {name, list}) do
    new_list = Todo.List.add_entry(list, entry)
    Todo.Database.store(name, new_list)
    {:reply, :ok, {name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {_, list} = state) do
    {:reply, Todo.List.entries(list, date), state}
  end

  @impl GenServer
  def handle_call({:delete_entry, id}, _from, {name, list}) do
    new_list = Todo.List.delete_entry(list, id)
    {:reply, :ok, {name, new_list}}
  end

  @impl GenServer
  def handle_continue(:init, {name, nil}) do
    list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, list}}
  end
end
