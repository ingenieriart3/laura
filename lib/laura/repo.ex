defmodule Laura.Repo do
  use Ecto.Repo,
    otp_app: :laura,
    adapter: Ecto.Adapters.Postgres
end
