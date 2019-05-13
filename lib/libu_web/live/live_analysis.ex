defmodule LibuWeb.LiveAnalysis do
  use Phoenix.LiveView
  alias LibuWeb.AnalysisView
  alias Libu.Analysis

  def mount(_session, %{} = socket) do
    {:ok, assign(socket,
      analysis_session: Analysis.start_session(),
      analysis: "Nothing yet."
    )}
  end

  def render(assigns) do
    AnalysisView.render("live_analysis.html", assigns)
  end

  def handle_event("say", %{"msg" => msg}, socket) when is_nil(msg) do
    {:noreply, socket}
  end
  def handle_event("say", %{"msg" => msg}, %{assigns: %{analysis_session: session}} = socket)
  when is_binary(msg) do
    case Analysis.analyze(session, msg) do
      {:ok, analysis} ->
        {:noreply, assign(socket, analysis: Integer.to_string(analysis))}
      _ ->
        {:noreply, socket}
    end
  end

end
