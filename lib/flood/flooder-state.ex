defmodule Flood.FlooderState do
  use Agent

  def start_link(_initial_value), do:
    Agent.start_link(fn -> %{} end, name: __MODULE__)

  def get_flooders(), do:
    Agent.get(__MODULE__, & &1)

  def add_flooder(name, flooder) do
    Agent.update(__MODULE__, &(Map.put(&1, name, flooder)))
    notify_live_view()
  end

  def remove_flooder(name) do
    Agent.update(__MODULE__, &(Map.delete(&1, name)))
    notify_live_view()
  end

  def subscribe_live_view() do
    Phoenix.PubSub.subscribe(Flood.PubSub, "flooders_update", link: true)
  end

  def notify_live_view() do
    Phoenix.PubSub.broadcast(Flood.PubSub, "flooders_update", {__MODULE__, get_flooders()})
  end
end
