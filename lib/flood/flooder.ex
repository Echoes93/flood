defmodule Flood.Flooder do
  use GenServer
  import FloodWeb.FloodersChannel, only: [notify: 2]

  # API
  def start_link(name, t, opts \\ []), do:
    GenServer.start_link(__MODULE__, {name, t, opts}, name: via_registry(name))
  def new_timeout(server, t), do: GenServer.cast(server, {:new_timeout, t})
  def stop(name), do: GenServer.stop(via_registry(name))

  # CALLBACKS
  def init({name, timeout, opts}) do
    notify(:flooder_added, name)
    GenServer.cast(self(), :loop)

    {:ok, {timeout, name, opts}}
  end

  def handle_cast(:loop, {timeout, name, opts}) do
    pid = self()
    ## ACTION

    {:ok, {status, _}} = handle_request(opts[:url], opts[:method] || :get)
    IO.puts "Flooder #{name}: request status: #{status}"

    spawn fn ->
      Process.sleep timeout
      GenServer.cast(pid, :loop)
    end

    {:noreply, {timeout, name, opts}}
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

  defp handle_request(url, method) do
    {:ok, status, respheaders, _client} = :hackney.request(
      method,
      url,
      []
    )
    {:ok, {status, respheaders}}
  end
end
