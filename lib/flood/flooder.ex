defmodule Flood.Flooder do
  use GenServer
  import FloodWeb.FloodersChannel, only: [notify: 2]

  # API
  def start_link(name, url, opts \\ []), do:
    GenServer.start_link(__MODULE__, {name, url, opts}, name: via_registry(name))
  def new_timeout(server, t), do: GenServer.cast(server, {:new_timeout, t})
  def stop(name), do: GenServer.stop(via_registry(name))

  # CALLBACKS
  def init({name, url, opts}) do
    notify(:flooder_added, name)
    GenServer.cast(self(), :loop)

    {:ok, {name, url, opts}}
  end

  def handle_cast(:loop, {name, url, opts}) do
    pid = self()
    ## ACTION

    {:ok, method, timeout, headers, body} = get_opts(opts)

    {:ok, {status}} = handle_request(url, method, headers, body)
    IO.puts "Flooder #{name}: request status: #{status}"

    spawn fn ->
      Process.sleep timeout
      GenServer.cast(pid, :loop)
    end

    {:noreply, {name, url, opts}}
  end

  def handle_cast({:new_timeout, new_timeout}, {name, url, opts}) do
    {:ok, _, timeout, _, _} = get_opts(opts)
    IO.puts "Flooder #{name}: changed timeout: #{timeout} -> #{new_timeout}"

    {:noreply, {name, url, opts}}
  end

  def terminate(_reason, {_, name}) do
    notify(:flooder_removed, name)
  end

  # PRIVATE
  defp via_registry(name), do:
    {:via, Registry, {Flood.FlooderRegistry, name} }

  defp get_opts(opts) do
    %{
      method: method,
      timeout: timeout,
      headers: headers,
      body: body,
    } = Enum.into(
      opts,
      %{
        method: :get,
        timeout: 1000,
        headers: [],
        body: "",
      }
    )

    {:ok, method, timeout, headers, body}
  end

  defp handle_request(url, method, headers, body) do
    {:ok, status, _, client_ref} = :hackney.request(
      method,
      url,
      headers,
      body
    )
    {:ok, _} = :hackney.body(client_ref)

    Flood.Monitor.inc()
    IO.puts "Request count #{Flood.Monitor.get_request_count()}"

    {:ok, {status}}
  end
end
