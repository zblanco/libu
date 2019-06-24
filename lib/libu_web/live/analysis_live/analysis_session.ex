defmodule LibuWeb.LiveAnalysis do
  @moduledoc """
  A Text Editing LiveView session with the Analysis Context.

  Nests Liveviews based on the analyzer config.

  This liveview's responsibility is resonsible for activating UI for nested liveviews and handling text inputs.

  It should only tell the Analysis Session of text changes and active analyzers.

  The Session Process setup during `mount/2` of this LiveView is responsible for backend communication such as
    managing subscriptions, and calling analyzers to minimizing the the interface exposed here.
  """
  use Phoenix.LiveView
  alias LibuWeb.AnalysisView
  alias Libu.Analysis
  alias Phoenix.LiveView.Socket

  def mount(session, %Socket{} = socket) do
    socket =
      if connected?(socket) do
        id = UUID.uuid4()
        Analysis.setup_session(id)
        Analysis.subscribe(id)

        assign(socket,
            session_id: id,
            analyzer_config: default_analyzer_config(),
            results: %{})
      else
        assign(socket,
          analyzer_config: default_analyzer_config(),
          results: %{})
      end
    IO.inspect(session, label: "session: ")
    IO.inspect(socket, label: "socket: ")
    {:ok, socket}
  end

  def default_analyzer_config do
    %{
      editing: false,
      text: false,
      difficulty: false,
      sentiment: false,
    }
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

  def render(assigns) do
    AnalysisView.render("analysis_session.html", assigns)
  end

  def handle_event("say", %{"msg" => msg}, %{assigns: %{session_id: session}}) do
    Analysis.analyze(session, msg)
  end

  def handle_event("toggle_analyzer", analyzer, %{assigns: %{session_id: session}}) do
    Analysis.toggle_analyzer(session, analyzer)
  end

end
