defmodule Libu.MixProject do
  use Mix.Project

  def project do
    [
      app: :libu,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Libu.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.0-rc.0", override: true},
      {:phoenix_pubsub, "~> 2.0", override: true},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:phoenix_live_view, "~> 0.12.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:calendar, "~> 0.17.4"},
      {:elixir_uuid, "~> 1.2"},
      {:veritaserum, "~> 0.2.1"},
      {:flow, "~> 0.14.3"},
      {:broadway, "~> 0.5.0"},
      {:essence, "~> 0.2.0"},
      {:argon2_elixir, "~> 2.0"},
      {:commanded, github: "zblanco/commanded", override: true},
      {:eventstore, "~> 1.0.0"},
      {:commanded_eventstore_adapter, "~> 1.0.0"},
      {:commanded_ecto_projections, "~> 1.0.0"},
      {:eventually, "~> 1.1"},
      {:phoenix_live_dashboard, "~> 0.1.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "event_store.init": ["event_store.drop", "event_store.create", "event_store.init"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["event_store.init", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
