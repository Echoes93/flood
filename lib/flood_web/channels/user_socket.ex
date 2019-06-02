defmodule FloodWeb.UserSocket do
  use Phoenix.Socket

  channel "flooders", FloodWeb.FloodersChannel

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
