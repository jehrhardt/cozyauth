defmodule Supapasskeys.PasskeysTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration
  alias Supapasskeys.WebAuthn.RelyingParty

  describe "registrations" do
    import Supapasskeys.ServersFixtures
    import Supapasskeys.PasskeysFixtures

    @invalid_attrs %{state: nil, user_id: nil}

    setup do
      {:ok,
       %{
         relying_party: %RelyingParty{
           name: Faker.Company.name(),
           origin: "https://#{Faker.Internet.domain_name()}"
         },
         server: server_fixture()
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
      assert {:error, %Ecto.Changeset{}} =
               Passkeys.create_registration(server, relying_party, @invalid_attrs)
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

      assert {:error, %Ecto.Changeset{}} =
               Passkeys.update_registration(server, registration, @invalid_attrs)

      assert registration == Passkeys.get_registration!(server, registration.id)
    end
  end
end
