defmodule Libu.Metrics do
  @moduledoc """
  Responsible for collection and preparation of metrics within Libu.

  ### Implementation Options:

  For extending Collector behaviours:

    * Our other contexts build functions that return a valid `%Metric{}`
      * or Our other contexts build functions that construct valid keyword params for `build_metric/2`
    * Our other contexts implement Collector modules per-metric or type of calculation
      * We could inject a default struct definition with whatever module name and extra keys defined
      * Overridable `new/1` for validation of parameters into a workable Collector state.

  Messaging:

    * Directly subscribe/publish to `Messaging` (couples to Libu.Messaging albeit through a simple interface)
    * Require explicit delivery of messages to spawned collector processes by name (uses Registry)
      * The context controlling the metrics itself would be responsible for subscribing to internal Metrics messages
    * Define a `PubSub` behaviour and require an implementation passed into Metrics at runtime.
      * Metrics will always publish messages such as `{:metric_result_prepared, "some unique metric name"}`
        * This lets a LiveView process subscribe to the metrics topic on the same pub sub or handle a redirected message from the context
    * Upon startup of these Collection processes we can setup a `Source` for the collected data:
      * A source might be `:telemetry` with required opts to `attach/4` the Collector
        (we may need metadata and a routing layer if telemetry doesn't support this kind of runtime behaviour)

  Supervision & Runtime Lifecycles:

    * If Metrics were a separate library we would want the user to define their own Metrics application and put it in a supervision tree
      * By default Metrics would use that application when spawning a Collector process underneath.
    * How would we manage monitors and links between context processes which may be transient?

  What interface do we want?

    * Configuring a DishDash:

  ## Configuring the DishDash Application:

  ```elixir
  children = [
    {DishDash, [pub_sub: MyApp.PubSubAdapter]},
    ...
  ]
  ```
  ## Extend Collector Behaviours

  ```elixir
  defmodule MyMetricCollector do
    use DishDash.Collectors.SlidingWindow

    @impl true
    def handle_event(%SomeEvent{}, state) do
      # convert to DishDash.Event
      #
    end
  end
  ```
  Example Metric?
  ```elixir
  example_metric = %Metric{
    name: "sentiment_score_over_time:session-12345",
    collector: %SlidingWindow{
      supervisor: Libu.Analysis.SessionMetricsSupervisor,
      source: {:pub_sub, [
        pub_sub: Libu.Metrics.MessagingPubSubAdapter,
        topic: Libu.Analysis.topic() <> "session-12345",
      ]},
      window: {:minutes, 2},
    },
  }

  iex> Libu.Metrics.run_metric(example_metric)
  > :ok

  def my_sliding_window_metric(session_id), do: %Metric{
    name: "sentiment_score_over_time:session-"<> session_id,
    collector: %SlidingWindow{
      supervisor: Libu.Analysis.SessionMetricsSupervisor,
      source: {:pub_sub, [
        pub_sub: Libu.Metrics.MessagingPubSubAdapter,
        topic: Libu.Analysis.topic() <> session_id,
      ]},
      window: {:minutes, 2},
    },
  }
  ```

  ** The Collector processes here could be separated into another library once generic enough. **
  """
  alias Libu.Messaging
  alias Libu.Metrics.{
    Metric,
    MetricsSupervisor,
  }

  def topic, do: inspect(__MODULE__)

  def subscribe(metric_name), do: Messaging.subscribe("#{topic()}:#{metric_name}")
  def subscribe(),            do: Messaging.subscribe(topic())

  @doc """
  Accepts a map or keyword list of params to build a valid `%Metric{}`

  ```elixir
  iex> Metrics.build_metric(
    "cpu usage over time",
    collector: [
      type: :sliding_window,
      window: {:seconds, 60},
    ],
  )
  iex> {:ok, %Metric{name: "cpu usage over time"}}
  ```
  """
  def build_metric(metric_name, opts \\ []) do
    opts
    |> Keyword.put(:name, metric_name)
    |> Metric.new()
  end

  def run_metric(%Metric{} = metric) do

  end

  @doc """
  Attach this function Telemetry to route to Collector processes.

  e.g. `:telemetry.attach("myapp-metrics", event, &Libu.Metrics.handle_telemetry_event/4, nil)`
  or   `:telemetry.attach_many("myapp-metrics", events, &Libu.Metrics.handle_telemetry_event/4, nil)`
  """
  def handle_telemetry_event(event_name, measurement, metadata, config) do
    # route to Collector process registered with the telemetry event name and/or metadata
    #
  end

end
