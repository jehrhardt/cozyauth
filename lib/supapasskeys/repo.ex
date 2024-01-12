defmodule Supapasskeys.Repo do
  use Ecto.Repo,
    otp_app: :supapasskeys,
    adapter: Ecto.Adapters.Postgres
end
