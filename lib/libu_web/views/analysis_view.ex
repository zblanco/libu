defmodule LibuWeb.AnalysisView do
  use LibuWeb, :view
  import Calendar.Strftime

  def time(utc_datetime) do
    strftime!(utc_datetime, "%r")
  end

  def is_analyzer_active?(analyzer, analyzer_config)
      when is_map(analyzer_config)
      when is_atom(analyzer) do
    Map.get(analyzer_config, analyzer)
  end
end
