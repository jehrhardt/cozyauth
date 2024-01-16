defmodule Supapasskeys.PasskeysTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Passkeys

  describe "registrations" do
    alias Supapasskeys.Passkeys.Registration

    import Supapasskeys.PasskeysFixtures

    @invalid_attrs %{state: nil, user_id: nil}

    test "get_registration!/1 returns the registration with given id" do
      registration = registration_fixture()
      assert Passkeys.get_registration!(registration.id) == registration
    end

    test "create_registration/1 with valid data creates a registration" do
      valid_attrs = %{
        id: Faker.UUID.v4(),
        name: Faker.Internet.email(),
        display_name: Faker.Person.name()
      }

      assert {:ok, %Registration{} = registration} = Passkeys.create_registration(valid_attrs)

      assert is_binary(registration.state)
      assert registration.user_id == valid_attrs.id
      assert is_binary(registration.creation_options)
    end

    test "create_registration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Passkeys.create_registration(@invalid_attrs)
    end

    test "update_registration/2 with valid data updates the registration" do
      registration = registration_fixture()
      update_state_json = Jason.encode!(%{"some" => "updated state"})
      update_attrs = %{state: update_state_json, user_id: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Registration{} = registration} =
               Passkeys.update_registration(registration, update_attrs)

      assert registration.state == update_state_json
      assert registration.user_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_registration/2 with invalid data returns error changeset" do
      registration = registration_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Passkeys.update_registration(registration, @invalid_attrs)

      assert registration == Passkeys.get_registration!(registration.id)
    end
  end

  describe "servers" do
    alias Supapasskeys.Passkeys.Server

    import Supapasskeys.PasskeysFixtures

    @invalid_attrs %{relying_party_name: nil, relying_party_origin: nil}

    test "list_servers/0 returns all servers" do
      server = server_fixture()
      assert Passkeys.list_servers() == [server]
    end

    test "get_server!/1 returns the server with given id" do
      server = server_fixture()
      assert Passkeys.get_server!(server.id) == server
    end

    test "create_server/1 with valid data creates a server" do
      valid_attrs = %{
        relying_party_name: "some relying_party_name",
        relying_party_origin: "some relying_party_origin"
      }

      assert {:ok, %Server{} = server} = Passkeys.create_server(valid_attrs)
      assert server.relying_party_name == "some relying_party_name"
      assert server.relying_party_origin == "some relying_party_origin"
    end

    test "create_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Passkeys.create_server(@invalid_attrs)
    end

    test "update_server/2 with valid data updates the server" do
      server = server_fixture()

      update_attrs = %{
        relying_party_name: "some updated relying_party_name",
        relying_party_origin: "some updated relying_party_origin"
      }

      assert {:ok, %Server{} = server} = Passkeys.update_server(server, update_attrs)
      assert server.relying_party_name == "some updated relying_party_name"
      assert server.relying_party_origin == "some updated relying_party_origin"
    end

    test "update_server/2 with invalid data returns error changeset" do
      server = server_fixture()
      assert {:error, %Ecto.Changeset{}} = Passkeys.update_server(server, @invalid_attrs)
      assert server == Passkeys.get_server!(server.id)
    end

    test "delete_server/1 deletes the server" do
      server = server_fixture()
      assert {:ok, %Server{}} = Passkeys.delete_server(server)
      assert_raise Ecto.NoResultsError, fn -> Passkeys.get_server!(server.id) end
    end

    test "change_server/1 returns a server changeset" do
      server = server_fixture()
      assert %Ecto.Changeset{} = Passkeys.change_server(server)
    end
  end
end
