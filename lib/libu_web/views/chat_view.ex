defmodule LibuWeb.ChatView do
  use LibuWeb, :view
  import Calendar.Strftime
  # alias Libu.Chat.Message

  def time(utc_datetime) do
    strftime!(utc_datetime, "%r")
  end
end
