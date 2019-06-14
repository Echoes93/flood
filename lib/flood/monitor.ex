defmodule Flood.Monitor do
  use Agent

  def start_link(initial_state), do:
    Agent.start_link(fn -> initial_state end, name: __MODULE__)

  def get_request_count(), do:
    Agent.get(__MODULE__, & &1[:request_count])

  def inc(), do:
    Agent.update(__MODULE__, fn(state) ->
      Keyword.put(state, :request_count, state[:request_count] + 1)
    end)
end
