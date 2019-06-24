defmodule Libu.Analysis do
  @moduledoc """
  Analyzes text on-demand with configurable strategies.

  Upon a change we queue up a text analysis job and always prioritize results from latest events.

  Upon receiving a `AnalysisResultProduced` event the parent session can update it's set of results per strategy.
  """
  alias Libu.Analysis.{
    SessionProcess,
    Session,
    Query,
    Persistence,
  }

  def topic, do: inspect(__MODULE__)

  @doc """
  Either starts a stateful session with a purpose to deliver serialized `TextChanged` events downstream, or
    refreshes a recent/existing one.

  # TODO: Enable a sticky, transient behavior with the Liveview/Browser session.
  """
  def setup_session(session_id) do
    with session  <- Session.new(session_id),
         {:ok, _} <- SessionProcess.start(session) do
      :ok
    else
      _ -> :error
    end
  end

  def subscribe(session_id) do
    Phoenix.PubSub.subscribe(Libu.PubSub, topic() <> ":#{session_id}")
  end

  defdelegate analyze(session_id, text),             to: SessionProcess
  defdelegate toggle_analyzer(session_id, analyzer), to: SessionProcess
  defdelegate fetch_analysis_results(session_id),    to: Query,       as: :fetch
  defdelegate setup_persistence,                     to: Persistence, as: :setup
end
