defmodule Libu.Analysis.Methods.Readability do
  @moduledoc """
  Metrics we want to collect:

  * Current reading difficulties
  * Reading difficulties over time
  """
  def dale_chall_difficulty(text) when is_binary(text) do
    text
    |> Essence.Document.from_text()
    |> Essence.Readability.dale_chall()
  end

  # def dalle_chall_reading_difficulty(topic_id), do: %Metric{
  #   name: :dale_chall_reading_difficulty,
  #   analyzer: &Libu.Analysis.Readability.dale_chall_difficulty/1,
  #   collector: :stateless, # stateless means latest value wins
  #   topic: topic,
  # }

  # def dalle_chall_reading_difficulty_over_time(topic_id, duration \\ 60_000) do
  #   name  = "dale_chall_reading_difficulty"
  #   topic = "#{topic_id}:#{name}"
  #   %Metric{
  #     name: name,
  #     analyzer: &Libu.Analysis.Readability.dale_chall_difficulty/1,
  #     collector: SlidingWindow.new(duration: duration, subscription: topic, broadcast_topic: "#{topic}"),
  #     topic: topic,
  #   }
  # end
end
