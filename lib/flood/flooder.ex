defmodule Flood.Flooder do
  use GenServer
  import FloodWeb.FloodersChannel, only: [notify: 2]

  # API
  def start_link(name, t \\ 1000), do:
    GenServer.start_link(__MODULE__, {name, t}, name: via_registry(name))
  def new_timeout(server, t), do: GenServer.cast(server, {:new_timeout, t})
  def stop(name), do: GenServer.stop(via_registry(name))

  # CALLBACKS
  def init({name, timeout}) do
    notify(:flooder_added, name)
    GenServer.cast(self(), :loop)

    {:ok, {timeout, name}}
  end

  def handle_cast(:loop, {timeout, name}) do
    pid = self()
    ## ACTION

    spawn fn ->
      Process.sleep timeout
      GenServer.cast(pid, :loop)
    end

    {:noreply, {timeout, name}}
  end

  def handle_cast({:new_timeout, new_timeout}, {timeout, name}) do
    IO.puts "Flooder #{name}: changed timeout: #{timeout} -> #{new_timeout}"

    {:noreply, {new_timeout, name}}
  end

  def terminate(_reason, {_, name}) do
    notify(:flooder_removed, name)
  end

  # PRIVATE
  defp via_registry(name), do:
    {:via, Registry, {Flood.FlooderRegistry, name} }
end
