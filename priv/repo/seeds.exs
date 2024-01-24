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
Supapasskeys.Repo.insert(%Supapasskeys.Servers.Server{
  relying_party_name: "Supapasskeys",
  relying_party_origin: "https://localhost:4000",
  subdomain: "test1"
})
