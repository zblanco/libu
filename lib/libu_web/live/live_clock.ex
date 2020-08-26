defmodule LibuWeb.LiveClock do
  use LibuWeb, :live_view
  import Calendar.Strftime

  def render(assigns) do
    ~L"""
    <div>
      <h3 class="font-sans text-2xl text-purple-800">It's <%= strftime!(@date, "%r") %></h3>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, put_date(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_date(socket)}
  end

  def handle_event("nav", _path, socket) do
    {:noreply, socket}
  end

  defp put_date(socket) do
    assign(socket, date: :calendar.local_time())
  end
end
