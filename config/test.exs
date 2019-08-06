use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :libu, LibuWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :libu, Libu.Repo,
  username: "postgres",
  password: "postgres",
  database: "libu_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :eventstore, EventStore.Storage,
  serializer: EventStore.TermSerializer,
  username: "postgres",
  password: "postgres",
  database: "libu_eventstore_test",
  hostname: "localhost",
  pool_size: 1
