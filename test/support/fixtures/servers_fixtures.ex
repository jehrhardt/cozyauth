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
        relying_party_name: Faker.Company.name(),
        relying_party_origin: "https://#{Faker.Internet.domain_name()}",
        subdomain: Faker.Internet.domain_word(),
        password: "supapasskeys",
        host: "localhost",
        port: 54329
      })
      |> Supapasskeys.Servers.create_server()

    {:ok, server} = Supapasskeys.Servers.migrate_server(server)

    server
  end
end
