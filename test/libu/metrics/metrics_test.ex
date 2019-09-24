defmodule Libu.MetricsTest do
  use ExUnit.Case
  alias Libu.Metrics
  alias Libu.Metrics.{Metric}

  def squareaplier(num), do: num * num



  describe "metric building" do
    test "we can build a valid last_value collector" do
      last_value_metric = Metrics.build("last_squared_value", [
        calculation: &squareaplier/1,
        collector: {:last_value, [

        ]}
      ])

      assert false
    end
  end

  # Metrics.build_metric("words_per_minute:#{session_id}", [
  #   collector: {:sliding_window,
  #     sliding_window_config(
  #       session_id,
  #       {:minutes, 1},
  #       &__MODULE__.handle_words_counted/1
  #     )
  #   }
  # ])

  describe "running metrics" do
    test "" do
      assert false
    end
  end
end
