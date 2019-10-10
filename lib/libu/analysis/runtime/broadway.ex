defmodule Libu.Analysis.Broadway do
  @moduledoc """
  Uses Broadway to operate our Job queue & processing.

  For acknowledgement Libu.Analysis doesn't care about failed jobs- the needs are very transient.

  The queue itself is all managed in-memory via :ets
  """
  use Broadway

  alias Broadway.Message

  alias Libu.Analysis.{JobProducer, Job}

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: AnalysisBroadway,
      producers: [
        default: [
          module: {JobProducer, []}
        ],
      ],
      processors: [
        default: [stages: 10]
      ]
    )
  end

  @impl true
  def handle_message(_processor, %Message{} = message, _context) do
    {:ok, ran_job} = Job.run(message.data)
    %Message{message | data: ran_job}
  end
end
