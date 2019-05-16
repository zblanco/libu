defmodule LibuWeb.LiveAnalysis do
  use Phoenix.LiveView
  alias LibuWeb.AnalysisView
  alias Libu.Analysis

  def mount(_session, %{} = socket) do
    if connected?(socket) do
      session = Analysis.start_session()
      Analysis.subscribe(session)
    end
    {:ok, assign(socket, session: session)}
  end

  defp fetch_results(%Socket{assigns: %{analysis_session: session}} = socket) do
    %{id: session_id} = session
    assign(socket, Analysis.fetch_analysis_results())
  end

  def handle_info({Analysis, [:analysis_results | _], _}, socket) do
    {:noreply, fetch_results(socket)}
  end

  def render(assigns) do
    AnalysisView.render("live_analysis.html", assigns)
  end

  def terminate(_, %{assigns: %{analysis_session: session}}) do
    Analysis.end_session(session)
  end

  def handle_event("say", %{"msg" => msg}, socket) when is_nil(msg) do
    {:noreply, socket}
  end
  def handle_event("say", %{"msg" => msg}, %{assigns: %{analysis_session: session}} = socket)
  when is_binary(msg) do
    case Analysis.handle_text_change(session, msg) do
      {:ok, analysis} ->
        {:noreply, assign(socket, analysis: analysis)}
      _ ->
        {:noreply, socket}
    end
  end

end
