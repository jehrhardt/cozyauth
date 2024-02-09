defmodule Supapasskeys.PasskeysTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration

  describe "registrations" do
    import Supapasskeys.ServersFixtures
    import Supapasskeys.PasskeysFixtures

    setup do
      server = server_fixture()
      relying_party = relying_party_fixture(server)

      {:ok,
       %{
         relying_party: relying_party,
         server: server
       }}
    end

    test "get_registration!/1 returns the registration with given id", %{
      relying_party: relying_party,
      server: server
    } do
      registration = registration_fixture(server, relying_party)
      assert Passkeys.get_registration!(server, registration.id) == registration
    end

    test "create_registration/1 with valid data creates a registration", %{
      relying_party: relying_party,
      server: server
    } do
      valid_attrs = %{
        id: Faker.UUID.v4(),
        name: Faker.Internet.email(),
        display_name: Faker.Person.name()
      }

      assert {:ok, %Registration{} = registration} =
               Passkeys.create_registration(server, relying_party, valid_attrs)

      assert is_binary(registration.state)
      assert registration.user_id == valid_attrs.id
      assert is_binary(registration.creation_options)
    end

    test "create_registration/1 with invalid data returns error changeset", %{
      relying_party: relying_party,
      server: server
    } do
      invalid_attrs = %{state: nil, user_id: nil}

      assert {:error, %Ecto.Changeset{}} =
               Passkeys.create_registration(server, relying_party, invalid_attrs)
    end

    test "update_registration/2 with valid data updates the registration", %{
      relying_party: relying_party,
      server: server
    } do
      registration = registration_fixture(server, relying_party)
      update_state_json = Jason.encode!(%{"some" => "updated state"})
      update_attrs = %{state: update_state_json, user_id: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Registration{} = registration} =
               Passkeys.update_registration(server, registration, update_attrs)

      assert registration.state == update_state_json
      assert registration.user_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_registration/2 with invalid data returns error changeset", %{
      relying_party: relying_party,
      server: server
    } do
      registration = registration_fixture(server, relying_party)
      invalid_attrs = %{state: nil, user_id: nil}

      assert {:error, %Ecto.Changeset{}} =
               Passkeys.update_registration(server, registration, invalid_attrs)

      assert registration == Passkeys.get_registration!(server, registration.id)
    end
  end

  describe "relying_parties" do
    alias Supapasskeys.Passkeys.RelyingParty
    import Supapasskeys.ServersFixtures
    import Supapasskeys.PasskeysFixtures

    setup do
      {:ok, %{server: server_fixture()}}
    end

    test "get_relying_party!/1 returns the relying_party with given id", %{server: server} do
      relying_party = relying_party_fixture(server)
      assert Passkeys.get_relying_party!(server, relying_party.id) == relying_party
    end

    test "create_relying_party/1 with valid data creates a relying_party", %{server: server} do
      valid_attrs = %{
        name: Faker.Internet.email(),
        origin: "https://#{Faker.Internet.domain_name()}"
      }

      assert {:ok, %RelyingParty{} = _relying_party} =
               Passkeys.create_relying_party(server, valid_attrs)
    end

    test "create_relying_party/1 with invalid data returns error changeset", %{server: server} do
      invalid_attrs = %{name: nil, origin: nil}
      assert {:error, %Ecto.Changeset{}} = Passkeys.create_relying_party(server, invalid_attrs)
    end

    test "update_relying_party/2 with valid data updates the relying_party", %{server: server} do
      relying_party = relying_party_fixture(server)
      update_attrs = %{}

      assert {:ok, %RelyingParty{} = _relying_party} =
               Passkeys.update_relying_party(server, relying_party, update_attrs)
    end

    test "update_relying_party/2 with invalid data returns error changeset", %{server: server} do
      relying_party = relying_party_fixture(server)
      invalid_attrs = %{name: nil, origin: nil}

      assert {:error, %Ecto.Changeset{}} =
               Passkeys.update_relying_party(server, relying_party, invalid_attrs)

      assert relying_party == Passkeys.get_relying_party!(server, relying_party.id)
    end

    test "delete_relying_party/1 deletes the relying_party", %{server: server} do
      relying_party = relying_party_fixture(server)
      assert {:ok, %RelyingParty{}} = Passkeys.delete_relying_party(server, relying_party)

      assert_raise Ecto.NoResultsError, fn ->
        Passkeys.get_relying_party!(server, relying_party.id)
      end
    end

    test "change_relying_party/1 returns a relying_party changeset", %{server: server} do
      relying_party = relying_party_fixture(server)
      assert %Ecto.Changeset{} = Passkeys.change_relying_party(relying_party)
    end
  end
end
