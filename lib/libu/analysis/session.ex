defmodule Libu.Analysis.Session do
  @moduledoc """
  Represents the state of a 1:1 LiveView session.
  """
  defstruct id: nil,
            text: "",
            edit_count: 0,
            analysis: %{
              overall_sentiment: 0,
              sentiment_score_per_word: 0,
              total_word_count: 0,
              words_count: 0,
            },
            start: nil

  def new(session_id) do
    struct(__MODULE__, [id: session_id, start: DateTime.utc_now()])
  end
end
