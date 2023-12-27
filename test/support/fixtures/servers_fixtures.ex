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
        database_name: "some database_name",
        host: "some host",
        password: "some password",
        port: 42,
        relying_party_name: "some relying_party_name",
        relying_party_url: "some relying_party_url",
        user: "some user"
      })
      |> Supapasskeys.Servers.create_server()

    server
  end
end
