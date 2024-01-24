defmodule Supapasskeys.ServerRepo do
  alias Supapasskeys.Servers.Server

  use Ecto.Repo,
    otp_app: :supapasskeys,
    adapter: Ecto.Adapters.Postgres

  def with_dynamic_repo(
        %Server{
          user: user,
          password: password,
          host: host,
          database_name: database_name,
          port: port
        },
        fun
      ) do
    default_dynamic_repo = get_dynamic_repo()

    {:ok, repo} =
      start_link(
        name: nil,
        username: user || "supapasskeys",
        password: password,
        hostname: host,
        database: database_name || "postgres",
        port: port || 5432
      )

    try do
      put_dynamic_repo(repo)
      fun.()
    after
      put_dynamic_repo(default_dynamic_repo)
      Supervisor.stop(repo)
    end
  end
end
