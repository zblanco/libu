# Libu

Link: http://libu.dev

A series of experimental features built around [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) capabilities.

Styled with [Tailwind CSS](https://github.com/tailwindcss/tailwindcss).

---

## Technicals

I wanted to see how viable using transient, in-memory representations of state for querying played out.

Currently the features center around Live Text Analysis and Chat Rooms. Phoenix Pub Sub is doing most of the messaging work from backend -> web.

The `Analysis` context uses Broadway for managing a dependent Job Processing pipeline of Text Editing Sessions. This Broadway pipeline is implemented with custom Producer using ETS Ordered Sets as a queue. `Analysis` uses a simple Job struct as to encapsulate job processing logic and support dependent jobs that can be adjusted at runtime. 

The chat features utilize Commanded for CQRS & Event Sourcing support. Chat persists to a Postgres-backed event store. The Projected/Query-models are built/rebuilt at runtime into ETS when necessary instead of persisting the projected state into a database.

Overall implementing Libu has been a good learning experience especially around usage of OTP, supervision trees, and ETS.

## Takeaways

Using ETS and GenServers as a caching layer is a decent idea, but better off as a future looking optimization instead of the upfront implementation. Just using Ecto and Postgres is definitely more productive as a Query layer. 

That said I think purely in-memory projections could be made much more practical with some abstractions around data collection & aggregation like was implemented concretely here. There's a lot of complexity in aggregating un-ordered messages especially at large volumes. However much of the supervision/OTP configuration & boilerplate along with ETS usage could be abstracted out into some process behaviours. 

It's also worth considering building metric aggregation into the Broadway pipeline instead of using (overusing) Phoenix Pub Sub. 

Finally, a DAG structure like the `%Analysis.Job{}` could be processed more efficiently than the current default of enqueuing dependent jobs with the results of the parent. In many cases you could use a series of optimizations like used in [Flow](https://github.com/plataformatec/flow) to minimize message passing and distribute work across stages.

<img align="center" alt="screenshot" src="libu-screenshot.png"/>

Take it for a spin:

  * Clone the repo: `git clone https://github.com/zblanco/libu.git`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Setup the event store with `mix do event_store.create, event_store.init`
  * Install Node.js dependencies with `npm install --prefix assets`
  * Start Phoenix endpoint with `mix phx.server` or `iex -S mix phx.server`

Visit [`localhost:4000`](http://localhost:4000) from your browser.

## Feature Notes

### Analysis

The goal was to render a rich analysis of whatever text you type.

We maintain a 1:1 Analysis Session with the LiveView using `DynamicSupervisor`. This session process receives text changes from the Live View and enqueues text processing jobs. Some of these jobs might be long-running or expensive, so we leave this interaction synchronous. Once an Analysis job is completed we can collect the results, build a read model and notify over pub sub where our LiveView can fetch the latest results.

### Chat

Chat features are a classic for Elixir/Phoenix demos. I wanted to deviate from the typical Phoenix Chat implementation that uses Ecto and Postgres for persistence and implement the query layer entirely in-memory. We can do this by event-sourcing our chat features and projecting our query state into ETS. We can easily layer on Text Analysis features to provide live insight into a conversation.

### Identity

We just want a minimal user model for persistence and deferred authentication via OAuth2 with Github. Some other contexts like Chat will require a `:current_user` to publish messages.

TODO:

## Text Analysis
- [x] Text Analysis Job processing
- [x] Live Text Analysis Sessions
- [ ] Toggled Metrics
- [ ] Windowed Metric Aggregations with histograms
- [ ] Wire up BERT
- [ ] Wire up Word2Vec

## Chat
- [x] Conversation LiveView
  - [x] Initial styling
  - [ ] TTL caching of each message
- [x] Event Sourced Persistence
- [x] Conversation Projection/Stream-Querying
- [x] Identity Integration
- [ ] Presence features
- [ ] Integrate Analysis Features
  - [ ] Run Sentiment during message drafting
  - [ ] Run metrics of conversation:
    - [ ] Leaderboards
    - [ ] Overall metrics
    - [ ] Windowed metrics

## Identity
- [x] Github OAuth Identity
- [x] Auth required routes
- [x] Avatar stuff