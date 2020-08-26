defmodule Libu.Analysis do
  @moduledoc """
  Analyzes text on-demand with configurable strategies.

  Upon a change we notify analysis strategies toggled at run-time for a session.

  There isn't an expectation of results from a Session, just notification to Analyzer Subscriber workers
    that there is work that `could` be done. This lets each Analyzer manage for its own load constraints independently.

  An Analyzer Subscriber handles an `AnalysisResultProduced` event produced by an Analyzer Strategy.

  The session can then prepare the results for Query and publish an `AnalysisResultPrepared` notifying
    our front-end that it can call `fetch_analysis_results/2`.
  """
  alias Libu.Analysis.{
    SessionProcess,
    Session,
    Query,
  }
  alias Libu.Messaging

  def topic, do: inspect(__MODULE__)

  def subscribe(session_id), do: Messaging.subscribe(topic() <> ":#{session_id}")
  def subscribe(),           do: Messaging.subscribe(topic())

  def setup_session() do
    with session  <- Session.new(),
         {:ok, _} <- SessionProcess.start(session) do
      {:ok, session.id}
    else
      _ -> :error
    end
  end

  defdelegate notify_text_changed(session_id, text),           to: SessionProcess
  defdelegate end_session(session_id),                         to: SessionProcess
  defdelegate fetch_analysis_results(session_id, metric_name), to: Query, as: :fetch
end
