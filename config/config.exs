# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :funbox,
  ecto_repos: [Funbox.Repo]

# Configures the endpoint
config :funbox, FunboxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4SQnUNzy9+x9spz1pAC8wAXcTx/KaoWTlKZivTVahB9sPLHBWCebQOmvSKvepRUg",
  render_errors: [view: FunboxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Funbox.PubSub,
  live_view: [signing_salt: "y6TlhsN4"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

import_config "#{Mix.env()}.exs"
import_config "git_config.exs"
