defmodule LibuWeb.LiveAnalysis do
  @moduledoc """

  """
  use Phoenix.LiveView
  alias LibuWeb.AnalysisView
  alias Libu.Analysis
  alias Phoenix.LiveView.Socket

  def mount(%{id: id}, %{} = socket) do
    if connected?(socket) do
      Analysis.setup_session(id)
      Analysis.subscribe(id)
      {:ok, socket}
    end
  end

  defp fetch_results(%Socket{assigns: %{analysis_session: session}} = socket) do
    %{id: session_id} = session
    {:ok, results} = Analysis.fetch_analysis_results(session_id)
    assign(socket, results: results)
  end

  # To Do, change to Analysis Result Produced event
  def handle_info({Analysis, [:analysis_results | _], _}, socket) do
    {:noreply, fetch_results(socket)}
  end

  # def handle_info({Analysis, [:analysis_results | _], _}, socket) do
  #   {:noreply, fetch_results(socket)}
  # end

  def render(assigns) do
    AnalysisView.render("live_analysis.html", assigns)
  end

  def terminate(_, %{assigns: %{analysis_session: session}}) do
    Analysis.end_session(session) # Not convinced this is the right approach we might should `Process.monitor/1` instead
  end

  def handle_event("say", %{"msg" => msg}, %{assigns: %{analysis_session: session}}) do
    Analysis.analyze(session, msg)
  end

end
