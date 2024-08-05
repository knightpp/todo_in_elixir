defmodule Todo.System do
  use Supervisor
  require Logger

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl Supervisor
  def init(_arg) do
    Logger.info("starting #{__MODULE__}")

    children = [
      Todo.ProcessRegistry,
      {Todo.Database, "./persist"},
      Todo.Cache
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
