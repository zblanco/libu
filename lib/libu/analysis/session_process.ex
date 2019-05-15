defmodule Libu.Analysis.SessionProcess do
  @moduledoc """
  Holds a set of Analyzer modules that a LiveView might call when some text changes.

  Using a Dynamic Supervisor we maintain a 1:1 Analysis Session with a LiveView.

  In an ideal world the LiveView connects and agrees to a send us Operational Transform events based on edits.
  From there we rebuild the text into it's latest version stored in ets.
  Each configured analyzer is queued analysis jobs based on the full text state.
  When the analyzer is done, the result is resolved back to the session state then stored in ETS.
    - Late results that have been preceded by another job of the same analyzer with fresher state are discarded.
  Whenever an analysis change is made, we publish to a pub sub where our LiveView client can be notified to refetch the analysis results for a session.
  ```

  Basic Lifecycle:

  * @first live view mount: start an analysis session under a Dynamic Supervisor with the initial state
  * @live view de-mount: kill the analysis session
  * @text change: call the analyzer modules, update and return the result in the `analysis` map.

  """
  use GenServer
  alias Libu.Analysis.{
    Session,
    BasicSentiment,
    Utilities,
    AnalysisResult,
    # Persistence,
    # Query,
  }

  def child_spec(session_id) do
    %{
      id: {__MODULE__, session_id},
      start: {__MODULE__, :start_link, [session_id]},
      restart: :temporary,
    }
  end

  def start_link(session_id) do
    GenServer.start_link(
      __MODULE__,
      session_id,
      name: via(session_id)
    )
  end

  def start(session_id) do
    DynamicSupervisor.start_child(
      Libu.Analysis.SessionSupervisor,
      {__MODULE__, session_id}
    )
  end

  def init(session_id), do: {:ok, Session.new(session_id)}

  def analyze(session_id, text) do
    GenServer.call(via(session_id), {:analyze, text})
  end

  def handle_call({:analyze, text}, _from, %Session{edit_count: edit_count} = session) do
    with total_word_count             <- Utilities.number_of_words(text),
         words_count                  <- Utilities.word_count(text),
         {:ok, basic_sentiment_score} <- BasicSentiment.analyze(text)
    do
      new_analysis_results = %AnalysisResult{
        overall_sentiment: basic_sentiment_score,
        sentiment_score_per_word: basic_sentiment_score / total_word_count,
        total_word_count: total_word_count,
        words_count: words_count,
      }

      new_session = %Session{ session |
        analysis: new_analysis_results,
        text: text,
        edit_count: edit_count + 1,
      }
      {:reply, {:ok, new_session}, new_session}
    else
      _ -> {:reply, :error, session}
    end
  end

  def via(session_id) when is_binary(session_id) do
    {:via, Registry, {Libu.Analysis.SessionRegistry, session_id}}
  end
end