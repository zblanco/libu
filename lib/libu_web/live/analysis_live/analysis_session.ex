defmodule LibuWeb.AnalysisSession do
  @moduledoc """
  A Text Editing LiveView session with the Analysis Context.

  Nests Liveviews based on the analyzer config.

  This liveview's responsibility is resonsible for activating UI for nested liveviews and handling text inputs.

  It should only tell the Analysis Session of text changes and active analyzers.

  The Session Process setup during `mount/2` of this LiveView is responsible for backend communication such as
    managing subscriptions, and calling analyzers to minimize the Analysis API consumption here.
  """
  use Phoenix.LiveView
  alias LibuWeb.AnalysisView
  alias Libu.Analysis
  alias Libu.Analysis.Events.{
    TextChanged,
    AnalysisResultPrepared,
    AnalysisResultsPrepared,
  }
  alias Phoenix.LiveView.Socket

  def mount(_session, %Socket{} = socket) do
      if connected?(socket) do
        {:ok, session_id} = Analysis.setup_session()
        Analysis.subscribe(session_id)
        IO.puts "connected! #{session_id}"
        {:ok, assign(socket,
            session_id: session_id,
            event_log: [])}
      else
        {:ok, assign(socket, event_log: [])}
      end
  end

  # defp fetch_results(%Socket{assigns: %{session_id: session_id}} = socket, metric_name) do
  #   {:ok, results} = Analysis.fetch_analysis_results(session_id)
  #   assign(socket, results: results)
  # end

  # To Do, change to Analysis Result Produced event & fetch to prepared read model
  # def handle_info(%TextChanged{} = event, socket) do
  #   IO.inspect(event, label: "liveview_handling")
  #   {:noreply, assign(socket, event_log: [ event | socket.assigns.event_log ])}
  # end

  # def handle_info(%AnalysisResultProduced{} = event, socket) do
  #   IO.inspect(event, label: "liveview_handling")
  #   {:noreply, assign(socket, event_log: [ event | socket.assigns.event_log ])}
  # end

  def handle_info(%AnalysisResultsPrepared{metric_name: metric_name} = event, %Socket{assigns: %{session_id: session_id}} = socket) do
    IO.inspect(event, label: "liveview_handling")
    {:ok, results} = Analysis.fetch_analysis_results(session_id, metric_name)
    {:noreply, assign(socket, event_log: results)}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def render(assigns) do
    AnalysisView.render("analysis_session.html", assigns)
  end

  def handle_event("say", %{"msg" => msg}, %Socket{assigns: %{session_id: session_id}} = socket) do
    Analysis.notify_text_changed(session_id, msg)
    {:noreply, socket}
  end

  # def handle_event("toggle_analyzer", analyzer, %{assigns: %{session_id: session}}) do
  #   Analysis.toggle_analyzer(session, analyzer)
  # end

  def terminate(_, %Socket{assigns: %{session_id: session_id}}) do
    Analysis.end_session(session_id)
  end

end
