defmodule Libu.Analysis.SessionEventLog do
  @moduledoc """
  A collector/projection process responsible for consuming events produced by a session and preparing a read model.

  Consumes TextChanged and AnalysisResultProduced events, converts them to a generic "event" struct then stores the events in ETS.

  Publishes AnalysisResultPrepared event once state is ready in ETS for queries.

  TODO:

  * Only show last 50 or so messages (Sliding Window)
  * Sort by {version #, timestamp}
  """
  use GenServer

  alias Libu.Analysis.{
    Events.TextChanged,
    Events.AnalysisResultProduced,
    Events.AnalysisResultsPrepared,
    LoggedEvent,
    CollectorSupervisor,
  }
  alias Libu.Messaging

  def via(session_id) when is_binary(session_id) do
    CollectorSupervisor.collector_via(__MODULE__, session_id)
  end

  def start_link(session_id) do
    GenServer.start_link(
      __MODULE__,
      session_id,
      name: via(session_id)
    )
  end

  def fetch(session_id) do
    GenServer.call(via(session_id), :fetch)
  end

  def init(session_id) do
    tid = :ets.new(__MODULE__, [:set, :public])
    Libu.Analysis.subscribe(session_id)
    {:ok, %{session_id: session_id, tid: tid}}
  end

  def handle_info(%TextChanged{} = event, %{tid: tid} = state) do
    handle_event_to_log(event, tid)
    {:noreply, state}
  end

  def handle_info(%AnalysisResultProduced{} = event, %{tid: tid} = state) do
    handle_event_to_log(event, tid)
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def handle_call(:fetch, _from, %{tid: tid} = state) do
    results = :ets.tab2list(tid)
    |> Enum.map(fn {_key, logged_event} -> logged_event end)
    |> Enum.sort(fn event1, event2 ->
      event1.session_text_version < event2.session_text_version
      || event1.published_on < event2.published_on
    end)
    {:reply, {:ok, results}, state}
  end

  defp handle_event_to_log(event, tid) do
    with {:ok, logged_event} <- log_event(event, tid) do
      Messaging.publish(
        AnalysisResultsPrepared.new(logged_event.session_id, "session_event_log"),
        Libu.Analysis.topic() <> ":" <> logged_event.session_id
      )
    end
  end

  defp log_event(event, tid) do
    with logged_event <- LoggedEvent.new(event),
         true         <- insert_event(logged_event, tid)
    do
      {:ok, logged_event}
    else
      error -> {:error, error}
    end
  end

  defp insert_event(%LoggedEvent{published_on: published_on, session_text_version: version} = event, tid) do
    if :ets.info(tid, :size) == 40 do
      oldest_item = :ets.first(tid)
      :ets.delete(tid, oldest_item)
    end
    :ets.insert_new(tid, {{published_on, version}, event})
  end
end
