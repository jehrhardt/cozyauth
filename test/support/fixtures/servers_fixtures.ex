defmodule Supapasskeys.ServersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Supapasskeys.Servers` context.
  """

  @doc """
  Generate a server.
  """
  def server_fixture(attrs \\ %{}) do
    {:ok, server} =
      attrs
      |> Enum.into(%{
        database_url: "postgres://supapasskeys:supapasskeys@localhost:54329/postgres",
        subdomain: Faker.Internet.domain_word()
      })
      |> Supapasskeys.Servers.create_server()

    {:ok, server} = Supapasskeys.Servers.migrate_database(server)

    server
  end
end
