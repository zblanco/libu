defmodule Libu.Analysis.Methods.Readability do
  @moduledoc """
  Metrics we want to collect:

  * Current reading difficulties
  * Reading difficulties over time

  """
  alias Libu.Analysis.Metric
  def dale_chall_difficulty(text) when is_binary(text) do
    text
    |> Essence.Document.from_text()
    |> Essence.Readability.dale_chall()
  end

  # def dalle_chall_reading_difficulty(topic), do: %Metric{
  #   name: :dale_chall_reading_difficulty,
  #   analyzer: {Libu.Analysis.Readability, :dale_chall_difficulty},
  #   type: :stateless,
  #   topic: topic,
  # }

  # def dalle_chall_reading_difficulty_over_time(topic, duration), do: %Metric{
  #   name: :dale_chall_reading_difficulty,
  #   analyzer: {Libu.Analysis.Readability, :dale_chall_difficulty},
  #   type: %SlidingWindow{duration: },
  #   topic: topic,
  # }
end
