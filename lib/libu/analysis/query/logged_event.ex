defmodule Libu.Analysis.LoggedEvent do
  alias Libu.Analysis.Events.{AnalysisResultProduced, TextChanged}
  defstruct [
    :session_id,
    :event_type,
    :session_text_version,
    :published_on,
    :event,
  ]

  def new(%AnalysisResultProduced{} = event) do
    %__MODULE__{
      session_id: event.session_id,
      event_type: "analysis_result_produced",
      session_text_version: event.text_version,
      published_on: event.produced_on,
      event: Map.from_struct(event),
    }
  end

  def new(%TextChanged{} = event) do
    %__MODULE__{
      session_id: event.session_id,
      event_type: "text_changed",
      session_text_version: event.text_version,
      published_on: event.text_changed_on,
      event: Map.from_struct(event),
    }
  end
end
