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
  * @liveview de-mount: kill the analysis session (mercilessly) or keep hot for a period of time.
  * @text change: call the analyzer modules, update and return the result in the `analysis` map.

  """
  use GenServer
  alias Libu.Analysis.{
    Session,
    SimpleText,
    Utilities,
    AnalysisResult,
    Persistence,
    Query,
  }

  def via(session_id) when is_binary(session_id) do
    {:via, Registry, {Libu.Analysis.SessionRegistry, session_id}}
  end

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

  def init(session_id),
    do: {:ok, session_id, {:continue, :init}}

  def handle_continue(:init, session_id) do
    {:noreply, Query.fetch(session_id)}
  end


  def analyze(_session_id, text) when is_nil(text), do: {:error, :nothing_to_analyze}
  def analyze(session_id, text) do
    GenServer.call(via(session_id), {:analyze, text})
  end

  def handle_call({:analyze, text}, _from, session) do
    with {:ok, result} <- SimpleText.analyze(text) do

    end
    case SimpleText.analyze(text) do
      {:ok, result} ->
        new_session = %Session{ session |
        analysis: result
        edit_count: edit_count + 1,
      }
    end
  end


  def handle_call({:analyze, text}, _from, %Session{} = session) do






      {:reply, {:ok, new_session}, new_session}
    else
      _ -> {:reply, :error, session}
    end
  end
end
