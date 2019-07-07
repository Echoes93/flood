defmodule FloodWeb.MonitorLive do
  use Phoenix.LiveView

  alias Flood.Monitor, as: Monitor

  def render(assigns) do
    ~L"""
      <div class="monitor">
        <img width="120" src="/images/rocket.png"/>
        <h4>Performed request count - <%= @request_count %></h4>
      </div>
    """
  end

  def mount(_session, socket) do
    Monitor.subscribe_live_view()

    {:ok, assign(socket, request_count: Monitor.get_request_count())}
  end

  def handle_info({_requesting_module, request_count}, socket) do
    {:noreply, assign(socket, request_count: request_count)}
  end
end
