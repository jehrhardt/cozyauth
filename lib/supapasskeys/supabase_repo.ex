defmodule Supapasskeys.SupabaseRepo do
  use Ecto.Repo,
    otp_app: :supapasskeys,
    adapter: Ecto.Adapters.Postgres
end
