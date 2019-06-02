defmodule FloodWeb.FlooderChannelTest do
  use FloodWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      socket(FloodWeb.UserSocket, "user_id", %{some: :assign})
      |> subscribe_and_join(FloodWeb.FlooderChannel, "flooder:lobby")

    {:ok, socket: socket}
  end
end
