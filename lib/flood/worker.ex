defmodule Flood.Worker do
  use GenServer

  # API
  def start_link(name, t), do: GenServer.start_link(__MODULE__, t, name: via_registry(name))
  def new_t(server, t), do: GenServer.cast(server, {:new_t, t})
  def stop(name), do: GenServer.stop(via_registry(name))

  # CALLBACKS
  def init(t \\ 1000) do
    GenServer.cast(self(), :loop)

    {:ok, {t, 0}}
  end

  def handle_cast(:loop, {t, count}) do
    pid = self()
    IO.puts "Hey: #{count}"

    spawn fn ->
      Process.sleep t
      GenServer.cast(pid, :loop)
    end

    {:noreply, {t, count + 1}}
  end

  def handle_cast({:new_t, new_t}, {_, count}) do
    IO.puts "Changed t to: #{new_t}"

    {:noreply, {new_t, count}}
  end

  # PRIVATE
  defp via_registry(name), do: {:via, Registry, {Flood.WorkerRegistry, name} }
end
