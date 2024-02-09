# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Supapasskeys.Repo.insert!(%Supapasskeys.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
{:ok, server} =
  Supapasskeys.ServerRepo.insert(%Supapasskeys.Servers.Server{
    subdomain: "supapasskeys",
    database_url:
      System.get_env(
        "DATABASE_URL",
        "postgres://supapasskeys:supapasskeys@localhost:54329/postgres"
      )
  })

Supapasskeys.Servers.migrate_database(server)

Supapasskeys.Repo.with_dynamic_repo(server, fn ->
  Supapasskeys.Repo.insert(%Supapasskeys.Passkeys.RelyingParty{
    name: System.get_env("RELYING_PARTY_NAME", "Supapasskeys"),
    origin: System.get_env("RELYING_PARTY_ORIGIN", "http://localhost:4000")
  })
end)
