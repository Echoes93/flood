defmodule Flood.WorkerSupervisor do
  use DynamicSupervisor
  alias Flood.Worker

  def start_link(_arg),
    do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(child_name, t \\ 1000) do
    DynamicSupervisor.start_child(
      __MODULE__,
      %{id: Worker, start: { Worker, :start_link,  [child_name, t]}, restart: :transient})
  end
end
