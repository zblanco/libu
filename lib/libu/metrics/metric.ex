defmodule Libu.Metrics.Metric do
  @moduledoc """
  Represents a collectable set of data.

  Metrics are an abstraction for declaring a collectable set of data.

  A valid Metric contains all the config needed to start a Collector, aggregate messages from a source, and serve the data.

  A metric is used to spawn a collector process which consumes a given message on a topic and publishes MetricPrepared events once
    the queryable set of data has been prepared (usually in ETS).

  The Collectors are spawned by building a Child Spec that specfies how they're named and what supervises them.

  In the case of Analysis Sessions they're supervised underneath a Dynamic Session Metric Supervisor linked to
    the Session Process.

  This means when a Session ends, so do all the Collector Processes.
  """
  alias Libu.Metrics.Collectors.{
    EventConsumer,
    EventTriggeredPoller,
    Poller,
    SlidingWindow,
  }
  @enforce_keys [:name, :collector, :active?]
  defstruct ~w(
    name
    collector
    active?
  )a
  @type t :: %__MODULE__{
    name: metric_name, # used to register the collector process & query results
    collector: collector | module(), # callback module used to start and run the process
    active?: boolean,
  }

  @type id :: String.t
  @type metric_name :: {String.t, id} | String.t
  @type collector ::
    EventConsumer.t
    | EventTriggeredPoller.t
    | Poller.t
    | SlidingWindow.t
    | LastValue.t
    | module()

  def new(params) do
    # Building a metric should do nothing in the runtime other than return a data structure.
    # Configuration of the metric is mostly delegated to the Collector
    # Invalid configurations should be surfaced from here.
    {:ok, struct!(__MODULE__, params)}
  end

  # def child_spec_for(%Metric{collector: collector}), do: collector.child_spec()

  def deactivate(%__MODULE__{active?: true} = metric), do: %__MODULE__{metric | active?: false}

  def activate(%__MODULE__{active?: false} = metric),  do: %__MODULE__{metric | active?: true}
end
