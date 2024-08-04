defmodule Todo.Server do
  use GenServer

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %Todo.List{})
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
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:add_entry, entry}, _from, state) do
    state = Todo.List.add_entry(state, entry)
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, state) do
    {:reply, Todo.List.entries(state, date), state}
  end

  @impl GenServer
  def handle_call({:delete_entry, id}, _from, state) do
    state = Todo.List.delete_entry(state, id)
    {:reply, :ok, state}
  end
end
