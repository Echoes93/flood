defmodule Flood.Monitor do
  use Agent

  def start_link(_initial_value), do:
    Agent.start_link(fn -> 0 end, name: __MODULE__)

  def get_request_count(), do:
    Agent.get(__MODULE__, & &1)

  def increment(), do:
    Agent.update(__MODULE__, &(&1 + 1))
end
