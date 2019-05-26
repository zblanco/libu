defmodule Libu.Analysis.Events.TextChanged do
  @moduledoc """
  Published by a SessionProcess when the Text to Analyze has been changed.
  """
  defstruct [
    :session_id,
    :text_version,
    :text_changed_on,
    :text,
  ]
end
