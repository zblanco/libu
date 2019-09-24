defmodule Libu.Analysis.Methods.Editing do
  @moduledoc """
  Used to build editing state such as how long the editing session has lasted, how many edits have taken place, etc.

  An aggregator process supervised under a Session that builds a sliding window of state for the editing of some text.

  Consumed AnalysisResultProduced events to calculate various metrics about text editing.

  ## Metrics to track:

  * # of Changes / Current Text Version
  * Frequency of changes over time
    * Changes per x period in the last few minutes
    * Polls
  * Words Per Minute
    * Sliding Window (1 minute) that keeps an ordered set of the word count
  * Editing Session Length
    * Just a running calculation that takes DateTime.utc_now - Session Start
  * Time since last edit
    * running calculation that takes DateTime.utc_now - Last Edited On
  """
  alias Libu.Analysis.Events.{TextChanged, AnalysisResultProduced}

  alias Libu.Metrics

  def time_since(%DateTime{} = older_time) do
    DateTime.diff(DateTime.utc_now, older_time)
  end

  def words_per_minute(session_id) do
    Metrics.build_metric("words_per_minute:#{session_id}", [ # considering this api
      collector: {:sliding_window,
        sliding_window_config(
          session_id,
          {:minutes, 1},
          &__MODULE__.handle_words_counted/1
        )
      }
    ])
  end

  def handle_words_counted(%AnalysisResultProduced{result: result})
  when is_integer(result) do
    {:ok, result}
  end

  def sliding_window_config(session_id, window, event_handler) do
    [
      supervisor: Libu.Analysis.SessionMetricsSupervisor,
      source: {:pub_sub, [
        pub_sub: Libu.Metrics.MessagingPubSubAdapter,
        topic: "#{Libu.Analysis.topic}#{session_id}",
      ]},
      window: window,
      handler: event_handler,
    ]
  end
end
