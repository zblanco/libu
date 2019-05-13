defmodule Libu.Analysis.SessionProcess do
  @moduledoc """
  Holds a set of Analyzer modules that a LiveView might call when some text changes.

  Using a Dynamic Supervisor we maintain a 1:1 Analysis Session with a LiveView.

  initial state:
  ```elixir
  %Session{
    session_id: "an id we share with the liveview session"
    analyzers: [naive_sentiment: Libu.Analysis.NaiveSentiment],
    text: "",
    analysis: %{},
  }
  ```

  Basic Lifecycle:

  * @first live view mount: start an analysis session under a Dynamic Supervisor with the initial state
  * @live view de-mount: kill the analysis session
  * @text change: call the analyzer modules, update and return the result in the `analysis` map.

  """
  use GenServer
  alias Libu.Analysis.{Session, NaiveSentiment}

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

  def handle_call({:analyze, text}, _from, %Session{} = session) do
    with {:ok, rating} <- NaiveSentiment.analyze(text) do
      {:reply, {:ok, rating}, %Session{ session |
        analysis: [naive_analysis: rating]
      }}
    else
      _ -> {:reply, :error, session}
    end
  end

  def via(session_id) when is_binary(session_id) do
    {:via, Registry, {Libu.Analysis.SessionRegistry, session_id}}
  end
end
