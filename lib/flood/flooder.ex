defmodule Flood.Flooder do
  use GenServer
  import FloodWeb.FloodersChannel, only: [notify: 2]

  # API
  def start_link(name, url, opts \\ []), do:
    GenServer.start_link(__MODULE__, {name, url, 1, opts}, name: via_registry(name))
  def new_timeout(server, t), do: GenServer.cast(server, {:new_timeout, t})
  def stop(name), do: GenServer.stop(via_registry(name))

  # CALLBACKS
  def init({name, url, counter, opts}) do
    notify(:flooder_added, name)
    GenServer.cast(self(), :loop)

    {:ok, {name, url, counter, opts}}
  end

  def handle_cast(:loop, {name, url, counter, opts}) do
    pid = self()
    ## ACTION

    {:ok, method, timeout, headers, body} = get_opts(opts)

    {:ok, {status}} = handle_request(url, method, headers, body)
    IO.puts "Flooder #{name}: request status: #{status}, request count: #{counter}"

    spawn fn ->
      Process.sleep timeout
      GenServer.cast(pid, :loop)
    end

    {:noreply, {name, url, counter + 1, opts}}
  end

  def handle_cast({:new_timeout, new_timeout}, {name, url, counter, opts}) do
    {:ok, _, timeout, _, _} = get_opts(opts)
    IO.puts "Flooder #{name}: changed timeout: #{timeout} -> #{new_timeout}"

    {:noreply, {name, url, counter, opts}}
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
    {:ok, status, _, _} = :hackney.request(
      method,
      url,
      headers,
      body
    )

    {:ok, {status}}
  end
end
