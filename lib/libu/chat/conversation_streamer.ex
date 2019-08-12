defmodule Libu.Chat.ConversationStreamer do
  @moduledoc """
  Process responsible for maintaining an ordered set ETS table of a conversation.

  We can either: maintain in-memory projections of all active conversations (cleaning up old conversations and recreating only if needed)
    or
  Try and be clever and only maintain the actual messages that have been read recently, responding to queries by streaming in events
   from the eventstore and rebuilding the state to persist to ets on demand.
  """
end
