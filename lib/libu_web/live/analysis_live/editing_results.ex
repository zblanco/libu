defmodule LibuWeb.LiveAnalysis.EditingResults do
  @moduledoc """
  Renders results from an Analysis Session about text editing.
  """
  use Phoenix.LiveView
  alias LibuWeb.AnalysisView
  alias Libu.Analysis
  alias Phoenix.LiveView.Socket

  def mount(_session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    AnalysisView.render("editing_results.html", assigns)
  end

  # def handle_info() do
    # handle EditingResultsUpdated event?
  # end
end
