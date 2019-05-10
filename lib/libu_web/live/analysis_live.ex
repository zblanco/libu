defmodule LibuWeb.AnalysisLive do
  use Phoenix.LiveView

  def mount(_session, socket) do
    if connected?(socket), do: Analysis.subscribe()

    {:ok, assign(socket,
      analyzer_options: Analysis.analyzer_options(),
      analyzer_config: Analysis.start_session(),
    )}
  end

  def render(assigns) do
    ChatView.render("live_chat.html", assigns)
  end

  def handle_event("say", %{"msg" => msg}, socket) when is_binary(msg) do
    analysis =
      msg
      |> Veritaserum.analyze()
      |> Integer.to_string()

    {:noreply, assign(socket, analysis: analysis)}
  end
  def handle_event("say", %{"msg" => _}, socket) do
    {:ok, assign(socket, analysis: "Nothing yet, type something below.")}
  end
end
