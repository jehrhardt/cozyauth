defmodule Supapasskeys.ServersTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Servers

  describe "servers" do
    alias Supapasskeys.Servers.Server

    import Supapasskeys.ServersFixtures

    @invalid_attrs %{subdomain: nil, database_url: nil, migrated_at: nil}

    test "list_servers/0 returns all servers" do
      server = server_fixture()
      assert Servers.list_servers() == [server]
    end

    test "get_server!/1 returns the server with given id" do
      server = server_fixture()
      assert Servers.get_server!(server.id) == server
    end

    test "create_server/1 with valid data creates a server" do
      valid_attrs = %{subdomain: "some subdomain", database_url: "some database_url", migrated_at: ~U[2024-02-08 05:22:00Z]}

      assert {:ok, %Server{} = server} = Servers.create_server(valid_attrs)
      assert server.subdomain == "some subdomain"
      assert server.database_url == "some database_url"
      assert server.migrated_at == ~U[2024-02-08 05:22:00Z]
    end

    test "create_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Servers.create_server(@invalid_attrs)
    end

    test "update_server/2 with valid data updates the server" do
      server = server_fixture()
      update_attrs = %{subdomain: "some updated subdomain", database_url: "some updated database_url", migrated_at: ~U[2024-02-09 05:22:00Z]}

      assert {:ok, %Server{} = server} = Servers.update_server(server, update_attrs)
      assert server.subdomain == "some updated subdomain"
      assert server.database_url == "some updated database_url"
      assert server.migrated_at == ~U[2024-02-09 05:22:00Z]
    end

    test "update_server/2 with invalid data returns error changeset" do
      server = server_fixture()
      assert {:error, %Ecto.Changeset{}} = Servers.update_server(server, @invalid_attrs)
      assert server == Servers.get_server!(server.id)
    end

    test "delete_server/1 deletes the server" do
      server = server_fixture()
      assert {:ok, %Server{}} = Servers.delete_server(server)
      assert_raise Ecto.NoResultsError, fn -> Servers.get_server!(server.id) end
    end

    test "change_server/1 returns a server changeset" do
      server = server_fixture()
      assert %Ecto.Changeset{} = Servers.change_server(server)
    end
  end
end
