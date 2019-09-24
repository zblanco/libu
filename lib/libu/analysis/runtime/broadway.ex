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
      name: __MODULE__,
      producers: [
        default: [
          module: {JobProducer, []},
          transformer: {__MODULE__, :transform, []}
        ],
      ],
      processors: [
        default: [stages: 10]
      ]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    IO.puts "attempting to process #{message.data.__struct__}"
    message |> Message.update_data(&run_job/1)
  end

  def run_job(%Message{data: %Job{} = job} = message) do
    {:ok, ran_job} = Job.run(job)
    %Message{message | data: ran_job}
  end

  def transform(event, _opts) do
    %Message{
      data: event,
      acknowledger: nil,
    }
  end
end
