defmodule Libu.Analysis.Session do
  @moduledoc """
  """
  alias Libu.Analysis.NaiveSentiment

  defstruct session_id: nil,
            analyzers: [
              naive_sentiment: NaiveSentiment
            ],
            text: "",
            analysis: %{
              naive_sentiment: 0
            }

  def new(session_id) when is_binary(session_id) do
    struct(__MODULE__, [session_id: session_id])
  end

  def start, do: UUID.uuid4()
end
