defmodule FloodWeb.FloodersLive do
  use Phoenix.LiveView

  alias Flood.FlooderState, as: State

  def render(assigns) do
    ~L"""
      <div>
        <%= FloodWeb.FlooderView.render("form.html", assigns) %>
        <%= FloodWeb.FlooderView.render("list.html", assigns) %>
      </div>
    """
  end

  def mount(_session, socket) do
    State.subscribe_live_view()

    {:ok, assign(
      socket,
      flooder: %{
        "url" => "",
        "name" => "",
        "body" => "",
        "timeout" => 600,
        "method" => "get",
      },
      flooders: State.get_flooders()
    )}
  end

  def handle_event("on_change", params, socket) do
    %{"flooder" => flooder} = params

    {:noreply, assign(
      socket,
      flooder: flooder
    )}
  end

  def handle_event("remove", value, socket) do
    Flood.FlooderSupervisor.stop_child(value)
    State.remove_flooder(value)

    {:noreply, socket}
  end

  def handle_event("generate", _params, socket) do
    flooder = socket.assigns[:flooder]

    generate_flooder(flooder)

    State.add_flooder(flooder["name"], flooder)

    {:noreply, assign(
      socket,
      flooder: %{
        "url" => "",
        "name" => "",
        "body" => "",
        "timeout" => 600,
        "method" => "get",
      }
    )}
  end

  def handle_info({_requesting_module, flooders}, socket) do
    {:noreply, assign(socket, flooders: flooders)}
  end

  defp generate_flooder(params) do
    %{"name" => name, "url"=> url, "method"=> method, "body"=> body} = params
    Flood.FlooderSupervisor.start_child(name, url, %{method: method, body: body})
  end
end
