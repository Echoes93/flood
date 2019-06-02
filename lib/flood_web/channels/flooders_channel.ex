defmodule FloodWeb.FloodersChannel do
  use FloodWeb, :channel

  def notify(:flooder_added, flooder) do
    FloodWeb.Endpoint.broadcast!("flooders", "flooder_created", %{"flooder" => flooder})
  end

  def notify(:flooder_removed, flooder) do
    FloodWeb.Endpoint.broadcast!("flooders", "flooder_removed", %{"flooder" => flooder})
  end

  def join("flooders", _payload, socket) do
    {:ok, socket}
  end
end
