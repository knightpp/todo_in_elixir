defmodule Todo.Database do
  use GenServer

  @spec start(String.t()) :: GenServer.on_start()
  def start(dir \\ "./persist") do
    GenServer.start(__MODULE__, dir, name: __MODULE__)
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
    {:ok, dir}
  end

  @impl GenServer
  def handle_cast({:store, key, value}, dir) do
    file_name(key, dir) |> File.write!(:erlang.term_to_binary(value))
    {:noreply, dir}
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
