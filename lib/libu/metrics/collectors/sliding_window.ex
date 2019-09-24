defmodule Libu.Metrics.Collectors.SlidingWindow do
  @moduledoc """
  A Sliding Window Collector maintains an ordered set of messages within a Window range of time or count.

  As new messages are added, old messages that don't fit the new window are removed.
  """
  @behaviour Libu.Metrics.Collectors.Collector

  alias Libu.Metrics.Metric
  # defmacro __using__(opts \\ [window: {:seconds, 60}]) do


  #   def process_event()
  # end

  defstruct ~w(name window source)a
  @type t :: %__MODULE__{
    name: name(),
    window: window(),
    source: source(),
  }

  @type source ::
    {:pub_sub, pub_sub_opts}
    | :manual
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

  @type window() ::
    {:milliseconds, integer}
    | {:seconds, integer}
    | {:minutes, integer}
    | {:count, integer}

  # def new(%Metric{collector: %__MODULE__{} = config} = metric) do
  #   with :ok <- config_valid?(config) do
  #     new(metric)
  #   else
  #     {:error, config_errors} -> {:error, config_errors}
  #   end
  # end

  def new(params) do
    struct!(__MODULE__, params) # must return errors
  end

  use GenServer

  def via(%__MODULE__{} = sliding_window) do
    {:via, Registry, {Libu.Metrics.CollectorRegistry, sliding_window.name}}
  end

  def child_spec(%__MODULE__{} = sliding_window) do
    %{
      id: {__MODULE__, sliding_window.name},
      start: {__MODULE__, :start_link, [sliding_window]},
      restart: :temporary,
    }
  end

  def start_link(%__MODULE__{} = sliding_window) do
    GenServer.start_link(__MODULE__, sliding_window, name: via(sliding_window))
  end

  def init(%__MODULE__{} = sliding_window) do
    {:ok, sliding_window, {:continue, :init}}
  end

  def handle_continue(:init, %__MODULE__{source: {:pub_sub, topic: topic, pub_sub: pub_sub}} = sliding_window) do
    with :ok <- pub_sub.subscribe(topic) do
      setup_ets(sliding_window)
      {:noreply, sliding_window}
    end
  end

  def start(%__MODULE__{} = sliding_window) do
    DynamicSupervisor.start_child(
      Libu.Metrics.CollectorSupervisor,
      {__MODULE__, sliding_window}
    )
  end

  # def process_event(name, )

  # def handle_info()

  defp setup_ets(%__MODULE__{name: name}),
    do: :ets.new({__MODULE__, name}, [:ordered_set])

end
