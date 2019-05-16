defmodule LibuWeb.LiveAnalysis do
  use Phoenix.LiveView
  alias LibuWeb.AnalysisView
  alias Libu.Analysis

  def mount(_session, %{} = socket) do
    {:ok, socket}
  end

  def render(assigns) do
    AnalysisView.render("live_analysis.html", assigns)
  end

  def handle_event("say", %{"msg" => msg}, socket) when is_nil(msg) do
    {:noreply, socket}
  end
  def handle_event("say", %{"msg" => msg}, socket) when is_binary(msg) do
    with results <- Analysis.analyze(text) do
      {:noreply, assign(socket, analysis: results)}
    else
      _ -> {:noreply, socket}
    end
  end

end
