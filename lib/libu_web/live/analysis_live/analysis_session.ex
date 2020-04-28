defmodule LibuWeb.AnalysisSession do
  @moduledoc """
  A Text Editing LiveView session with the Analysis Context.

  Nests Liveviews based on the analyzer config.

  This liveview's responsibility is resonsible for activating UI for nested liveviews and handling text inputs.

  It should only tell the Analysis Session of text changes and active analyzers.

  The Session Process setup during `mount/2` of this LiveView is responsible for backend communication such as
    managing subscriptions, and calling analyzers to minimize the Analysis API consumption here.
  """
  use LibuWeb, :live_view
  alias Libu.Analysis
  alias Libu.Analysis.Events.{
    AnalysisResultProduced,
    AnalysisResultsPrepared,
  }
  alias Phoenix.LiveView.Socket

  def mount(_params, _session, %Socket{} = socket) do
    if connected?(socket) do
      {:ok, session_id} = Analysis.setup_session()
      Analysis.subscribe(session_id)

      {:ok, assign(socket, session_id: session_id) |> assign_defaults()}
    else
      {:ok, assign_defaults(socket)}
    end
  end

  def assign_defaults(socket) do
    assign(socket,
      event_log: [],
      sentiment_score: 0,
      readability: 0,
      total_count_of_words: 0,
      average_sentiment_per_word: 0,
      word_counts: %{}
    )
  end

  def handle_info(
    %AnalysisResultsPrepared{metric_name: "session_event_log"},
    %Socket{assigns: %{session_id: session_id}} = socket
  ) do
    with {:ok, results} <- Analysis.fetch_analysis_results(session_id, "session_event_log") do
      {:noreply, assign(socket, event_log: results)}
    end
  end

  def handle_info(%AnalysisResultProduced{metric_name: metric_name, result: result}, socket) do
    socket =
      case metric_name do
        :total_count_of_words ->
          assign(socket, total_count_of_words: result)
        :dale_chall_difficulty ->
          assign(socket, readability: result |> :erlang.float_to_binary([decimals: 2]))
        :word_counts ->
          assign(socket, word_counts: result)
        :basic_sentiment ->
          assign(socket, sentiment_score: result)
        :average_sentiment_per_word ->
          assign(socket, average_sentiment_per_word: result |> :erlang.float_to_binary([decimals: 2]))
      end

    {:noreply, socket}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def handle_event("say", %{"msg" => msg}, %Socket{assigns: %{session_id: session_id}} = socket) do
    Analysis.notify_text_changed(session_id, msg)
    {:noreply, socket}
  end

  def terminate(_, %Socket{assigns: %{session_id: session_id}}) do
    Analysis.end_session(session_id)
  end
end
