defmodule Libu.Repo do
  use Ecto.Repo,
    otp_app: :libu,
    adapter: Ecto.Adapters.Postgres
end
