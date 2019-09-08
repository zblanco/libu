defmodule Libu.Analysis.Session do
  @moduledoc """
  Represents the state of a 1:1 LiveView session.
  """
  alias Libu.Analysis.{
    Sentiment,
    Text,
    Editing,
    Difficulty,
  }

  defstruct id: nil,
            text: "",
            version: 0,
            active_analyzers: %{},
            start: nil,
            last_edited_on: nil

  def new(session_id) do
    struct(__MODULE__, [
      id: session_id,
      start: DateTime.utc_now(),
      active_analyzers: default_analyzer_config(),
    ])
  end

  def increment_version(%__MODULE__{version: version} = session) do
    %__MODULE__{session |
    version: version + 1
    }
  end

  defp default_analyzer_config do
    for {k, _v} <- analyzers_by_key(), into: %{}, do: {k, true}
  end

  def analyzer_for_key(key) when is_atom(key) do
    Map.get(analyzers_by_key(), key)
  end

  def available_analyzer?(analyzer) do
    Map.has_key?(analyzers_by_key(), analyzer)
  end

  def analyzers_by_key do
    %{
      text: Text,
      editing: Editing,
      sentiment: Sentiment,
      difficulty: Difficulty,
    }
  end

  # def new(session_id, active_analyzers: []) do
    # Consider how or if the Liveview should set default analyzers
  # end

  def set_text(%__MODULE__{version: version} = session, text)
  when is_binary(text) do
    %__MODULE__{session |
      version: version + 1,
      text: text,
      last_edited_on: DateTime.utc_now(),
    }
  end

  def toggle_analyzer(
    %__MODULE__{active_analyzers: active_analyzers} = session,
      analyzer
  ) do
    toggle = Map.get(active_analyzers, analyzer)
    case toggle do
        nil -> session
        _ -> %__MODULE__{ session |
          active_analyzers: %{active_analyzers | analyzer => !toggle}
        }
    end
  end
end
