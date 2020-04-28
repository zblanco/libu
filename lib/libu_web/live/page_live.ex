defmodule LibuWeb.PageLive do
  use LibuWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="mt-10 mx-auto max-w-screen-xl px-4 sm:mt-12 sm:px-6 md:mt-16 lg:mt-20 xl:mt-28">
      <div class="text-center">
        <h2 class="text-4xl tracking-tight leading-10 font-extrabold text-gray-900 sm:text-5xl sm:leading-none md:text-6xl">
          <span class="text-purple-600">LIBU</span>
        </h2>
        <p class="mt-3 max-w-md mx-auto text-base text-gray-600 sm:text-lg md:mt-5 md:text-xl md:max-w-3xl">
          A series of Liveview experiments.

          Styled with Tailwind CSS Utilities.
        </p>

        <p class="mt-3 max-w-md mx-auto text-base text-gray-500 sm:text-lg md:mt-5 md:text-xl md:max-w-3xl">
          You can find the repo <%= link("here", to: "https://github.com/zblanco/libu", class: "text-purple-800") %>.
        </p>
        <div class="mt-5 max-w-md mx-auto sm:flex sm:justify-center md:mt-8">
          <%= live_render(@socket, LibuWeb.LiveClock, id: "live-clock") %>
        </div>
      </div>
    </div>
    """
  end

end
