# Libu

A series of experimental features built around [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) capabilities.

Styled with [Tailwind CSS](https://github.com/tailwindcss/tailwindcss).

<img align="center" alt="screenshot" src="libu-screenshot.png"/>

TODO:

## Text Analysis
- [x] Text Analysis Job processing
- [x] Live Text Analysis Sessions
- [ ] Toggled Metrics

## Projects
- [x] Live CRUD with FSM Changeset validation
- [x] KanBan LiveView of FSM
- [ ] Pagination, Sorting & Filters
- [ ] Search
- [ ] Voting
- [ ] Github Repo Integration

## Chat
- [ ] Conversation LiveView
  - [x] Initial styling
- [x] Event Sourced Persistence
- [x] Conversation Projection/Stream-Querying
- [ ] Identity Integration
- [ ] Project Chats

## Identity
- [x] Github OAuth Identity
- [ ] Auth required routes
- [x] Avatar stuff

Take it for a spin:

  * Clone the repo: `git clone https://github.com/zblanco/libu.git`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Switch back to the project directory `cd ../`
  * Start Phoenix endpoint with `mix phx.server` or `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Feature Notes

### Projects

To start I wanted to get a feel for how LiveView works with the typical CRUD app. Turns out it works really well and a weekend in I had full CRUD actions on a Project model. Implementing a Kanban view was easy with our friend `Enum.group_by`. 

The plan is to use this to try out pagination, search, list-views, and other basic admin interface capabilities. I'm considering changing this Project Management context into more of a Liveview Project Sharing featureset with voting, view counting, commenting, and Github integrations. The Kanban features can be pulled out into a Dashboarding library instead.

### Analysis

The goal was to render a rich analysis of whatever text you type.

We maintain a 1:1 Analysis Session with the LiveView using `DynamicSupervisor`. This session process receives text changes from the Live View and enqueues text processing jobs. Some of these jobs might be long-running or expensive, so we leave this interaction synchronous. Once an Analysis job is completed we can collect the results, build a read model and notify over pub sub where our LiveView can fetch the latest results.

*A further optimization is to only send Operational Transform events to our Analyis Session to minimize copying the whole contents each edit. Pushing around OT messages like this is also a good way to lead into collaborative features. We can do OT from the LiveView -> Session, but we'd rather do that from the Client -> LiveView && Session to really minimizing payload sizes.*

### Chat

Chat features are a classic for Elixir/Phoenix demos. I wanted to deviate from the typical Phoenix Chat implementation that uses Ecto and Postgres for persistence and implement the query layer entirely in-memory. We can do this by event-sourcing our chat features and projecting our query state into ETS. We can easily layer on Text Analysis features to provide live insight into a conversation.

For viewing a conversation/chat-room we can use a similar Liveview 1:1 Session approach as `Text Analysis` but keeping tabs on where the User is in the Conversation so we can stream down only the visible messages of the Conversation. As needed we stream messages from the Event Store into ETS.

### Identity

We just want a minimal user model for persistence and deferred authentication via OAuth2 with Github. Some other contexts like Chat will require a `:current_user` to publish messages.