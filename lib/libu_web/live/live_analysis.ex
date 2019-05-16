defmodule LibuWeb.LiveAnalysis do
  use Phoenix.LiveView
  alias LibuWeb.AnalysisView
  alias Libu.Analysis

  def mount(_session, %{} = socket) do
    {:ok, assign(socket, analysis: %{
      overall_sentiment: 0,
      sentiment_score_per_word: 0,
      total_word_count: 0,
      words_count: 0,
    })}
  end

  def render(assigns) do
    AnalysisView.render("live_analysis.html", assigns)
  end

  def handle_event("say", %{"msg" => msg}, socket) when is_nil(msg) do
    {:noreply, socket}
  end
  def handle_event("say", %{"msg" => msg}, socket) when is_binary(msg) do
    with results <- Analysis.analyze(msg) do
      {:noreply, assign(socket, analysis: results)}
    else
      _ -> {:noreply, socket}
    end
  end

end
