defmodule Libu.Analysis.Events.TextChanged do
  @moduledoc """
  Published by a SessionProcess when the Text to Analyze has been changed.
  """
  alias Libu.Analysis.Session
  defstruct [
    :session_id,
    :text_version,
    :text_changed_on,
    :text,
  ]

  def new(%Session{} = session) do
    %__MODULE__{
      session_id: session.id,
      text_version: session.changes,
      text_changed_on: session.last_edited_on,
      text: session.text,
    }
  end
end
