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
        database_url: "some database_url",
        migrated_at: ~U[2024-02-08 05:22:00Z],
        subdomain: "some subdomain"
      })
      |> Supapasskeys.Servers.create_server()

    server
  end
end
