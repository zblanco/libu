# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :libu,
  ecto_repos: [Libu.Repo]

# Configures the endpoint
config :libu, LibuWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wgulZ17IG1bmDpVOs32xJnCTD9JSpx27Lglw5nPKfP7vuesHrHFp4c2zNW7AHzdN",
  render_errors: [view: LibuWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Libu.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "eHwaY+4fde9j2pR4dHhhEKUA3p72cwVk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix,
  json_library: Jason,
  template_engines: [leex: Phoenix.LiveView.Engine]

# config :commanded_ecto_projections,
#   repo: Libu.Repo

config :libu, event_stores: [Libu.EventStore]

config :libu, Libu.Chat.Commanded,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: Libu.Chat.EventStore
  ],
  pub_sub: :local,
  registry: :local

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
