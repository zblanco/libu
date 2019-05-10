defmodule LibuWeb.LiveChat do
  use Phoenix.LiveView
  alias LibuWeb.ChatView
  alias Libu.Chat

  def mount(_session, socket) do
    if connected?(socket), do: Chat.subscribe()

    {:ok, assign(socket, analysis: "Nothing yet, type something below.")}
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
