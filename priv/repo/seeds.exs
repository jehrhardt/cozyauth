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
%Supapasskeys.Servers.Server{
  port: 54329,
  user: "postgres",
  host: "localhost",
  password: "postgres",
  database_name: "postgres",
  relying_party_url: "http://localhost:4000",
  relying_party_name: "Supapasskeys"
}
|> Supapasskeys.Repo.insert!()
|> Supapasskeys.Servers.migrate_server()
