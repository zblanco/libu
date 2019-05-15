defmodule LibuWeb.ChatView do
  use LibuWeb, :view
  import Calendar.Strftime

  def first_message_body(%{messages: messages} = _conv) when is_list(messages) do
    %{body: body} = List.first(messages)
    body
  end

  def time(utc_datetime) do
    strftime!(utc_datetime, "%r")
  end
end
