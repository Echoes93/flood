defmodule Flood.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      FloodWeb.Endpoint,
      Flood.Monitor,
      Flood.FlooderState,
      { Flood.FlooderSupervisor, [] },
      { Registry, [keys: :unique, name: Flood.FlooderRegistry] }
    ]

    opts = [strategy: :one_for_one, name: Flood.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    FloodWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
