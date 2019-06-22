defmodule FloodWeb.MonitorLive do
  use Phoenix.LiveView

  alias Flood.Monitor, as: Monitor

  def render(assigns) do
    ~L"""
      <h3>Performed requests count: <%= @request_count %></h3>
    """
  end

  def mount(_session, socket) do
    Monitor.subscribe_live_view()

    {:ok, assign(socket, request_count: 0)}
  end

  def handle_info({_requesting_module, request_count}, socket) do
    {:noreply, assign(socket, request_count: request_count)}
  end
end
