defmodule Flood.FlooderSupervisor do
  use DynamicSupervisor
  alias Flood.Flooder

  def start_link(_arg),
    do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(child_name, t \\ 1000), do:
    DynamicSupervisor.start_child(
      __MODULE__,
      %{id: Flooder, start: { Flooder, :start_link,  [child_name, t]}, restart: :transient})
end
