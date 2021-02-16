defmodule Funbox.Repo do
  use Ecto.Repo,
    otp_app: :funbox,
    adapter: Ecto.Adapters.Postgres
end
