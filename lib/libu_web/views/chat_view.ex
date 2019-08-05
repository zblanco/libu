defmodule LibuWeb.ChatView do
  use LibuWeb, :view
  import Calendar.Strftime
  alias Libu.Chat.{Conversation, Message}


  def first_message_body(%Conversation{messages: [%Message{body: body} | _]} = _conv) do
    body
  end

  def first_message_body(convo) do
    IO.inspect(convo)
    "body aint matching wtf"
  end

  def time(utc_datetime) do
    strftime!(utc_datetime, "%r")
  end
end
