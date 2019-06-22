defmodule FloodWeb.FloodersLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <div>
        <%= FloodWeb.FlooderView.render("form.html", assigns) %>
        <%= FloodWeb.FlooderView.render("flooder_list.html", assigns) %>
      </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(
      socket,
      flooder: %{
        "url" => "",
        "name" => "",
        "body" => "",
        "count" => 1,
        "timeout" => 600,
        "method" => "get",
      },
      flooder_list: []
    )}
  end

  def handle_event("on_change", params, socket) do
    %{"flooder" => flooder} = params

    {:noreply, assign(
      socket,
      flooder: flooder
    )}
  end

  def handle_event("generate", _params, socket) do
    flooder = socket.assigns[:flooder]
    flooder_list = socket.assigns[:flooder_list]

    { count, _ } = Integer.parse(flooder["count"])
    generate_flooder(flooder, count)

    {:noreply, assign(
      socket,
      flooder: %{
        "url" => "",
        "name" => "",
        "body" => "",
        "count" => 1,
        "timeout" => 600,
        "method" => "get",
      },
      flooder_list: flooder_list ++ [name: flooder]
    )}
  end

  defp generate_flooder(params, 1) do
    %{"name" => name, "url"=> url, "method"=> method, "body"=> body,} = params
    Flood.FlooderSupervisor.start_child("#{name}_1", url, %{method: method, body: body})
  end

  defp generate_flooder(params, n) do
    %{"name" => name, "url"=> url, "method"=> method, "body"=> body,} = params
    Flood.FlooderSupervisor.start_child("#{name}_#{n}", url, %{method: method, body: body})
    generate_flooder(params, n - 1)
  end
end
