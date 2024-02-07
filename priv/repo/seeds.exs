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
supabase_project_id = System.get_env("SUPABASE_PROJECT_ID", "supapasskeys")

{:ok, project} =
  Supapasskeys.Repo.insert(%Supapasskeys.Supabase.Project{
    name: supabase_project_id,
    reference_id: supabase_project_id,
    database_url:
      System.get_env(
        "DATABASE_URL",
        "postgres://supapasskeys:supapasskeys@localhost:54329/postgres"
      )
  })

Supapasskeys.Supabase.migrate_database(project)

Supapasskeys.SupabaseRepo.with_dynamic_repo(project, fn ->
  Supapasskeys.SupabaseRepo.insert(%Supapasskeys.Passkeys.RelyingParty{
    project_id: project.id,
    name: System.get_env("RELYING_PARTY_NAME", supabase_project_id),
    origin: System.get_env("RELYING_PARTY_ORIGIN", "http://localhost:4000")
  })
end)
