defmodule CozyAuth.Repo do
  use Ecto.Repo,
    otp_app: :cozyauth,
    adapter: Ecto.Adapters.Postgres
end
