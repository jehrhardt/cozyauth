defmodule Supapasskeys.PasskeysTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Passkeys

  describe "registrations" do
    alias Supapasskeys.Passkeys.Registration

    import Supapasskeys.PasskeysFixtures

    @invalid_attrs %{state: nil, user_id: nil}

    test "list_registrations/0 returns all registrations" do
      registration = registration_fixture()
      assert Passkeys.list_registrations() == [registration]
    end

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

    test "delete_registration/1 deletes the registration" do
      registration = registration_fixture()
      assert {:ok, %Registration{}} = Passkeys.delete_registration(registration)
      assert_raise Ecto.NoResultsError, fn -> Passkeys.get_registration!(registration.id) end
    end

    test "change_registration/1 returns a registration changeset" do
      registration = registration_fixture()
      assert %Ecto.Changeset{} = Passkeys.change_registration(registration)
    end
  end
end
