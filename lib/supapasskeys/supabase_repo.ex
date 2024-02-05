defmodule Supapasskeys.SupabaseRepo do
  alias Supapasskeys.Supabase.Project

  use Ecto.Repo,
    otp_app: :supapasskeys,
    adapter: Ecto.Adapters.Postgres

  def with_dynamic_repo(%Project{database_url: url}, fun) do
    default_dynamic_repo = get_dynamic_repo()

    {:ok, repo} =
      start_link(url: url)

    try do
      put_dynamic_repo(repo)
      fun.()
    after
      put_dynamic_repo(default_dynamic_repo)
      Supervisor.stop(repo)
    end
  end
end
