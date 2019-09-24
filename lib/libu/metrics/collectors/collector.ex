defmodule Libu.Metrics.Collectors.Collector do
  @moduledoc """
  Base behaviour implemented by other Collector behaviours.

  ## Generic behaviour to all collectors:

  * run_metric(%Metric{collector: __MODULE__, options: [...]})
    * Starts a given Collector provided required options are present
  * child_spec(%__MODULE__{supervisor: MyAppMetricSupervisor \\ DishDash.CollectorSupervisor})
    * Called by Supervisor at start
  * prepare_collector(%Metric{collector: __MODULE__, options: [...]})
    *
  """

  @type source ::
    {:pub_sub, pub_sub_opts}
    | function()
    | {:genstage_producer, any}
    | {:telemetry, telemetry_opts}

  @type pub_sub_opts :: [
    pub_sub: module,
    topic: String.t
  ]

  @type telemetry_opts :: [

  ]

  @type telemetry_event_name() :: String.t | list(atom)

  @type name() :: Libu.Metrics.Metric.name()

  @base_keys ~w(name source collector_supervisor)a



  # @callback child_spec() :: map

  # @callback init(args :: term) ::
  #   {:ok, Metric.t()}

  # @callback handle_prepared()



  # @callback start()

  # defmacro __using__(opts) do
  #   quote bind_quoted: [opts: opts] do
  #     @behaviour unquote(__MODULE__)

  #     @doc false
  #     def child_spec(arg) do
  #       default = %{
  #         id: __MODULE__,
  #         start: {__MODULE__, :start_link, [arg]}
  #       }

  #       Supervisor.child_spec(default, unquote(Macro.escape(opts)))
  #     end

  #     defoverridable child_spec: 1
  #   end
  # end
end
