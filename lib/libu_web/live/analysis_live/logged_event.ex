defmodule LibuWeb.LoggedEvent do
  use LibuWeb, :live_component

  def render(assigns) do
    ~L"""
    <li id="<%= @event.session_id %>_<%= @event.published_on %>">
      <div class="block hover:bg-gray-50 focus:outline-none border-b border-gray-100 text-sm">
        <div class="min-w-0 flex-1 sm:flex sm:items-center sm:justify-between">
          <div class="w-auto p-2 text-gray-700"><%= @event.event_type %></div>
          <div class="w-auto p-1 text-gray-700"><%= @event.session_text_version %></div>
          <div class="w-auto p-1 text-gray-700"><%= time(@event.published_on) %></div>
        </div>
      </div>
    </li>
    """
  end
end
