defmodule FloodWeb.Router do
  use FloodWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FloodWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/counter", FloodersLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", FloodWeb do
  #   pipe_through :api
  # end
end
