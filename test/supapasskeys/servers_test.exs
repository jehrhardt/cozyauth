defmodule Supapasskeys.ServersTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Servers

  describe "servers" do
    alias Supapasskeys.Servers.Server

    import Supapasskeys.ServersFixtures

    @invalid_attrs %{
      port: nil,
      user: nil,
      host: nil,
      password: nil,
      database_name: nil,
      relying_party_url: nil,
      relying_party_name: nil
    }

    test "list_servers/0 returns all servers" do
      server = server_fixture()
      assert Servers.list_servers() == [server]
    end

    test "get_server!/1 returns the server with given id" do
      server = server_fixture()
      assert Servers.get_server!(server.id) == server
    end

    test "create_server/1 with valid data creates a server" do
      valid_attrs = %{
        port: 42,
        user: "some user",
        host: "some host",
        password: "some password",
        database_name: "some database_name",
        relying_party_url: "some relying_party_url",
        relying_party_name: "some relying_party_name"
      }

      assert {:ok, %Server{} = server} = Servers.create_server(valid_attrs)
      assert server.port == 42
      assert server.user == "some user"
      assert server.host == "some host"
      assert server.password == "some password"
      assert server.database_name == "some database_name"
      assert server.relying_party_url == "some relying_party_url"
      assert server.relying_party_name == "some relying_party_name"
    end

    test "create_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Servers.create_server(@invalid_attrs)
    end

    test "update_server/2 with valid data updates the server" do
      server = server_fixture()

      update_attrs = %{
        port: 43,
        user: "some updated user",
        host: "some updated host",
        password: "some updated password",
        database_name: "some updated database_name",
        relying_party_url: "some updated relying_party_url",
        relying_party_name: "some updated relying_party_name"
      }

      assert {:ok, %Server{} = server} = Servers.update_server(server, update_attrs)
      assert server.port == 43
      assert server.user == "some updated user"
      assert server.host == "some updated host"
      assert server.password == "some updated password"
      assert server.database_name == "some updated database_name"
      assert server.relying_party_url == "some updated relying_party_url"
      assert server.relying_party_name == "some updated relying_party_name"
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
