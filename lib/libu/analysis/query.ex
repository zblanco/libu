defmodule Libu.Analysis.Query do
  alias Libu.Analysis.{
    SessionEventLog,
  }

  def fetch(session_id, "session_event_log") do
    SessionEventLog.fetch(session_id)
  end
end
