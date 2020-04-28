defmodule LibuWeb.Navatar do
  use LibuWeb, :live_component
  alias Libu.Identity

  def mount(_params, session, socket) do
    {:ok, socket |> assign(show_profile_menu: false) |> assign_current_user(session)}
  end

  defp assign_current_user(socket, %{"user_id" => user_id}) do
    assign(socket, current_user: Identity.get_user!(user_id))
  end

  defp assign_current_user(socket, _) do
    assign(socket, current_user: nil)
  end

  def handle_event("toggle-profile-menu", _, %{assigns: %{show_profile_menu: show}} = socket) do
    {:noreply, socket |> assign(show_profile_menu: !show)}
  end

  def handle_event("hide-profile-menu", _, socket) do
    {:noreply, socket |> assign(show_profile_menu: false)}
  end

  def render(assigns) do
    ~L"""

      <button
        phx-click="toggle-profile-menu"
        phx-blur="hide-profile-menu"
        phx-target="<%= @myself %>"
        class="flex items-center">
    <%= if @current_user do %>
        <img src="<%= @current_user.avatar_url %>"
            alt="avatar"
            class="w-8 h-8 rounded-full mr-2 hover:shadow-lg"
        />
    <% end %>
      </button>
    <%= if !@current_user do %>
      <%= link("Sign In", to: "/auth/github",
          class: "nav-item flex flex-no-grow flex-no-shrink"
      ) %>
    <% end %>

    <%= if @show_profile_menu do %>
      <div class="origin-top-right absolute right-0 mt-2 mr-2 w-56 bg-white rounded-lg shadow-md py-2 text-gray-800 text-sm">
        <ul>
          <li class="flex group block px-4 py-2 hover:bg-purple-100">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-4 text-gray-600 group-hover:text-purple-700 fill-current" viewBox="0 0 24 24">
              <path d="M9.715,12c1.151,0,2-0.849,2-2s-0.849-2-2-2s-2,0.849-2,2S8.563,12,9.715,12z"/><path d="M20,4H4C2.897,4,
                2,4.841,2,5.875v12.25C2,19.159,2.897,20,4,20h16c1.103,0,2-0.841,2-1.875V5.875C22,4.841,21.103,4,20,4z M20,18L4,17.989V6l16,0.011V18z"/>
              <path d="M14 9H18V11H14zM15 13H18V15H15zM13.43 15.536c0-1.374-1.676-2.786-3.715-2.786S6 14.162 6 15.536V16h7.43V15.536z"/>
            </svg>
            <a href="#" class="px-4 group-hover:text-purple-700">Profile</a>
          </li>
          <li class="flex group block px-4 py-2 hover:bg-purple-100">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-4 text-gray-600 group-hover:text-purple-700 fill-current" viewBox="0 0 24 24">
              <path d="M12,16c2.206,0,4-1.794,4-4s-1.794-4-4-4s-4,1.794-4,4S9.794,16,12,16z M12,10c1.084,0,2,0.916,2,2s-0.916,2-2,2 s-2-0.916-2-2S10.916,10,12,10z"/>
              <path d="M2.845,16.136l1,1.73c0.531,0.917,1.809,1.261,2.73,0.73l0.529-0.306C7.686,18.747,8.325,19.122,9,19.402V20 c0,1.103,0.897,2,2,2h2c1.103,0,2-0.897,
                2-2v-0.598c0.675-0.28,1.314-0.655,1.896-1.111l0.529,0.306 c0.923,0.53,2.198,0.188,2.731-0.731l0.999-1.729c0.552-0.955,
                0.224-2.181-0.731-2.732l-0.505-0.292C19.973,12.742,20,12.371,20,12 s-0.027-0.743-0.081-1.111l0.505-0.292c0.955-0.552,
                1.283-1.777,0.731-2.732l-0.999-1.729c-0.531-0.92-1.808-1.265-2.731-0.732 l-0.529,0.306C16.314,5.253,15.675,4.878,15,
                4.598V4c0-1.103-0.897-2-2-2h-2C9.897,2,9,2.897,9,4v0.598 c-0.675,0.28-1.314,0.655-1.896,1.111L6.575,
                5.403c-0.924-0.531-2.2-0.187-2.731,0.732L2.845,7.864 c-0.552,0.955-0.224,2.181,0.731,2.732l0.505,0.292C4.027,
                11.257,4,11.629,4,12s0.027,0.742,0.081,1.111l-0.505,0.292 C2.621,13.955,2.293,15.181,2.845,16.136z M6.171,13.378C6.058,
                12.925,6,12.461,6,12c0-0.462,0.058-0.926,0.17-1.378 c0.108-0.433-0.083-0.885-0.47-1.108L4.577,8.864l0.998-1.729L6.72,
                7.797c0.384,0.221,0.867,0.165,1.188-0.142 c0.683-0.647,1.507-1.131,2.384-1.399C10.713,6.128,11,5.739,11,5.3V4h2v1.3c0,
                0.439,0.287,0.828,0.708,0.956 c0.877,0.269,1.701,0.752,2.384,1.399c0.321,0.307,0.806,0.362,1.188,0.142l1.144-0.661l1,
                1.729L18.3,9.514 c-0.387,0.224-0.578,0.676-0.47,1.108C17.942,11.074,18,11.538,18,12c0,0.461-0.058,0.925-0.171,1.378 c-0.107,0.433,
                0.084,0.885,0.471,1.108l1.123,0.649l-0.998,1.729l-1.145-0.661c-0.383-0.221-0.867-0.166-1.188,0.142 c-0.683,0.647-1.507,1.131-2.384,
                1.399C13.287,17.872,13,18.261,13,18.7l0.002,1.3H11v-1.3c0-0.439-0.287-0.828-0.708-0.956
                c-0.877-0.269-1.701-0.752-2.384-1.399c-0.19-0.182-0.438-0.275-0.688-0.275c-0.172,0-0.344,0.044-0.5,0.134l-1.144,0.662l-1-1.729 L5.7,14.486C6.087,
                14.263,6.278,13.811,6.171,13.378z"/>
            </svg>
            <a href="#" class="px-4 group-hover:text-purple-700">Settings</a>
          </li>
          <li class="flex group block px-4 py-2 hover:bg-purple-100">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-4 text-gray-600 group-hover:text-purple-700 fill-current" viewBox="0 0 24 24"><path d="M16 13L16 11 7 11 7 8 2 12 7 16 7 13z"/>
              <path d="M20,3h-9C9.897,3,9,3.897,9,5v4h2V5h9v14h-9v-4H9v4c0,1.103,0.897,2,2,2h9c1.103,0,2-0.897,2-2V5C22,3.897,21.103,3,20,3z"/>
            </svg>
            <a href="#" class="px-4 group-hover:text-purple-700">Sign Out</a>
          </li>
        </ul>
      </div>
    <% end %>
    """
  end
end
