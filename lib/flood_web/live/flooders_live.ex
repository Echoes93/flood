defmodule FloodWeb.FloodersLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h1>Value: <%= @val %></h1>
      <button phx-click="error" class="alert-danger">Error</button>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, :val, 0)}
  end

  def handle_event("inc", _params, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end
end
