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

  @spec start_link(String.t()) :: Supervisor.on_start()
  def start_link(dir) do
    Logger.info("starting #{__MODULE__}")

    File.mkdir_p!(dir)

    children =
      1..@pool_size
      |> Enum.map(fn i -> worker_spec(dir, i) end)

    Supervisor.start_link(children, name: __MODULE__, strategy: :one_for_one)
  end

  @spec store(String.t(), term()) :: :ok
  def store(name, value) do
    Worker.store(choose_worker(name), name, value)
  end

  @spec get(String.t()) :: term()
  def get(name) do
    Worker.get(choose_worker(name), name)
  end

  @spec worker_spec(String.t(), number()) :: Supervisor.child_spec()
  defp(worker_spec(dir, worker_id)) do
    default_spec = {Todo.Database.Worker, {dir, worker_id}}
    Supervisor.child_spec(default_spec, id: worker_id)
  end

  @spec choose_worker(String.t()) :: non_neg_integer()
  defp choose_worker(key) do
    :erlang.phash2(key, 3) + 1
  end
end

defmodule Todo.Database.Worker do
  use GenServer
  require Logger

  def start_link({dir, worker_id}) do
    GenServer.start_link(__MODULE__, dir, name: via_tuple(worker_id))
  end

  @spec store(term(), String.t(), term()) :: :ok
  def store(key, name, value) do
    GenServer.call(via_tuple(key), {:store, name, value})
  end

  @spec get(term(), String.t()) :: term()
  def get(key, name) do
    GenServer.call(via_tuple(key), {:get, name})
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

  defp via_tuple(id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, id})
  end
end
