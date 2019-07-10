# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :flood, FloodWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CHbU7TwttgwWUJFnmj1PMm4j5xcZ5b8wq6rk4iGhkE5ubqHPvUHp0CqDBfwK/HkD",
  render_errors: [view: FloodWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Flood.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "OHw1g1Bj"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
