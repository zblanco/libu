defmodule Libu.Chat.Query.ConversationProjectionManager do
  @moduledoc """
  Manages a named ETS table that holds references to conversation projector tables.

  Monitors ConversationProjectors to prune references.

  TODO

  * lifecycle of the active_projector table
  * monitor conversation_projectors for unknown failures
  * also handle normal conversation endings
  """
end
