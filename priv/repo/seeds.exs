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
Supapasskeys.Repo.insert!(%Supapasskeys.Supabase.SupabaseProject{
  project_id: "supapasskeys",
  database_url: "ecto://postgres:postgres@127.0.0.1:54322/postgres"
})
