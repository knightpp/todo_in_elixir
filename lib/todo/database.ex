defmodule Todo.Database do
  alias Todo.Database.Worker
  use GenServer

  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(dir) do
    GenServer.start_link(__MODULE__, dir, name: __MODULE__)
  end

  @spec store(String.t(), term()) :: :ok
  def store(name, value) do
    GenServer.cast(__MODULE__, {:store, name, value})
  end

  @spec get(String.t()) :: term()
  def get(name) do
    GenServer.call(__MODULE__, {:get, name})
  end

  @impl GenServer
  def init(dir) do
    File.mkdir_p!(dir)

    workers =
      0..2
      |> Enum.map(fn i ->
        {:ok, pid} = Worker.start_link(dir)
        {i, pid}
      end)
      |> Map.new()

    {:ok, workers}
  end

  @impl GenServer
  def handle_cast({:store, key, value}, workers) do
    worker = choose_worker(key, workers)
    Worker.store(worker, key, value)
    {:noreply, workers}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, workers) do
    worker = choose_worker(key, workers)
    data = Worker.get(worker, key)

    {:reply, data, workers}
  end

  @spec choose_worker(String.t(), %{number() => GenServer.server()}) :: GenServer.server()
  defp choose_worker(key, workers) do
    Map.fetch!(workers, :erlang.phash2(key, 3))
  end
end

defmodule Todo.Database.Worker do
  use GenServer

  def start_link(dir) do
    GenServer.start_link(__MODULE__, dir)
  end

  @spec store(GenServer.server(), String.t(), term()) :: :ok
  def store(pid, name, value) do
    GenServer.call(pid, {:store, name, value})
  end

  @spec get(GenServer.server(), String.t()) :: term()
  def get(pid, name) do
    GenServer.call(pid, {:get, name})
  end

  @impl GenServer
  def init(dir) do
    {:ok, dir}
  end

  @impl GenServer
  def handle_call({:store, key, value}, _from, dir) do
    file_name(key, dir) |> File.write!(:erlang.term_to_binary(value))
    {:reply, :ok, dir}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, state) do
    data =
      case File.read(file_name(key, state)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end

  defp file_name(key, dir) do
    Path.join(dir, to_string(key))
  end
end
