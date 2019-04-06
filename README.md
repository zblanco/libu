# Libu

A basic project management tool juiced up with [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view).

Styled with [Tailwind CSS](https://github.com/tailwindcss/tailwindcss) Utilities.

<img align="center" alt="screenshot" src="libu-screenshot.png"/>

TODO:

- [x] Basic Clock Working
- [x] Live CRUD with FSM Changeset validation
- [x] KanBan LiveView of FSM
- [x] Styling
- [ ] Pagination, Sorting, Filters & Search

- [ ] Live Chat
- [ ] Github OAuth Identity
- [ ] Chat Persistence

Take it for a spin:

  * Clone the repo: `git clone https://github.com/zblanco/libu.git`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server` or `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.