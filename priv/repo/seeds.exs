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
  Supapasskeys.Repo.insert(%Supapasskeys.Servers.Server{
    subdomain: "test1",
    password: "supapasskeys",
    host: "localhost",
    port: 54329
  })

Supapasskeys.Servers.migrate_server(server)
