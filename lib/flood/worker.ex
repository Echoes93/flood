defmodule Flood.Worker do
  use GenServer

  # API
  def start_link(timeout) do
    GenServer.start_link(__MODULE__, timeout, [name: __MODULE__])
  end

  def new_t(new_timeout), do: GenServer.cast(__MODULE__, {:timeout, new_timeout})

  # CALLBACKS
  def init(timeout \\ 1000) do
    GenServer.cast(self(), :loop)

    {:ok, {timeout, 0}}
  end

  def handle_cast(:loop, {timeout, count}) do
    IO.puts "Hey: #{count}"

    spawn fn ->
      Process.sleep timeout
      GenServer.cast(__MODULE__, :loop)
    end

    {:noreply, {timeout, count + 1}}
  end

  def handle_cast({:timeout, new_timeout}, {_, count}) do
    IO.puts "Changed timeout to: #{new_timeout}"

    {:noreply, {new_timeout, count}}
  end
end
