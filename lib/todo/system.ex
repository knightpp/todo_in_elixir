defmodule Todo.System do
  use Supervisor

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl Supervisor
  def init(_arg) do
    children = [
      Todo.Cache
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
