defmodule FloodWeb.FloodersLive do
  use Phoenix.LiveView

  alias Flood.Monitor, as: Monitor

  def render(assigns) do
    ~L"""
    <div>
      <h3>request_count: <%= @request_count %></h3>

      <form phx-change="on_change" phx-submit="generate">
        <div>
          <input
            type="text"
            name="name"
            value="<%= @flooder_name %>"
            placeholder="Name for Flood"
          />
          <input
            type="text"
            name="url"
            value="<%= @request_url %>"
            placeholder="URL for Flood"
          />
        </div>
        <input
          type="number"
          name="count"
          min="1"
          value="<%= @flooder_count %>"
          placeholder="URL for Flood"
        />
        <button type="submit">Generate</button>
      </form>
      <ul>
        <%= for { _k, v } <- @flooder_list do %>
          <li><%= v %></li>
        <% end %>
      </ul>
    </div>
    """
  end

  def mount(_session, socket) do
    Monitor.subscribe_live_view()

    {:ok, assign(
      socket,
      request_count: 0,
      request_url: "",
      flooder_name: "",
      flooder_count: 1,
      flooder_list: []
    )}
  end

  def handle_event("on_change", %{"url" => url, "count" => count, "name" => name}, socket) do
    {:noreply, assign(
      socket,
      request_url: url,
      flooder_name: name,
      flooder_count: count
    )}
  end

  def handle_event("generate", %{"url" => url, "name" => name, "count" => count}, socket) do
    {intCount, _} = Integer.parse(count)
    generate_flooder({name, url}, intCount)

    flooder_list = socket.assigns[:flooder_list]
    new_list = flooder_list ++ [name: name]

    {:noreply, assign(
      socket,
      request_url: "",
      flooder_name: "",
      flooder_count: 1,
      flooder_list: new_list
    )}
  end

  @spec handle_info({any, any}, Phoenix.LiveView.Socket.t()) :: {:noreply, any}
  def handle_info({_requesting_module, request_count}, socket) do
    {:noreply, update(socket, :request_count, fn _value -> request_count end)}
  end

  defp generate_flooder({name, url}, 1), do:
    Flood.FlooderSupervisor.start_child("#{name}_1", url)

  defp generate_flooder({name, url}, n) do
    Flood.FlooderSupervisor.start_child("#{name}_#{n}", url)
    generate_flooder({name, url}, n - 1)
  end
end
