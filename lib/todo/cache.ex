defmodule Todo.Cache do
  use DynamicSupervisor
  require Logger

  @spec start_link(String.t()) :: Supervisor.on_start()
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec server_process(String.t()) :: pid()
  def server_process(list_name) do
    case DynamicSupervisor.start_child(__MODULE__, {Todo.Server, list_name}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  @impl DynamicSupervisor
  def init(_) do
    Logger.info("starting #{__MODULE__}")
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
