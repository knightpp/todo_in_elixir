defmodule Todo.Database do
  alias Todo.Database.Worker
  require Logger

  @pool_size 3

  def child_spec(dir) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [dir]},
      type: :supervisor
    }
  end

  def start_link(dir) do
    Logger.info("starting #{__MODULE__}")

    File.mkdir_p!(dir)

    Poolex.start_link(
      pool_id: __MODULE__,
      worker_module: Todo.Database.Worker,
      workers_count: @pool_size,
      worker_args: [dir]
    )
  end

  @spec store(String.t(), term()) :: :ok
  def store(name, value) do
    {:ok, result} =
      Poolex.run(__MODULE__, fn pid ->
        Worker.store(pid, name, value)
      end)

    result
  end

  @spec get(String.t()) :: term()
  def get(name) do
    {:ok, result} =
      Poolex.run(__MODULE__, fn pid ->
        Worker.get(pid, name)
      end)

    result
  end
end

defmodule Todo.Database.Worker do
  use GenServer
  require Logger

  def start_link(dir) do
    GenServer.start_link(__MODULE__, dir)
  end

  @spec store(term(), String.t(), term()) :: :ok
  def store(server, name, value) do
    GenServer.call(server, {:store, name, value})
  end

  @spec get(term(), String.t()) :: term()
  def get(server, name) do
    GenServer.call(server, {:get, name})
  end

  @impl GenServer
  def init(dir) do
    Logger.info("starting #{__MODULE__}")
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
