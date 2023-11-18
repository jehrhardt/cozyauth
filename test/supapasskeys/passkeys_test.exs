defmodule Supapasskeys.PasskeysTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Passkeys

  describe "passkey_registriations" do
    alias Supapasskeys.Passkeys.PasskeyRegistration

    import Supapasskeys.PasskeysFixtures

    @invalid_attrs %{state: nil, user_id: nil}

    test "list_passkey_registriations/0 returns all passkey_registriations" do
      passkey_registration = passkey_registration_fixture()
      assert Passkeys.list_passkey_registriations() == [passkey_registration]
    end

    test "get_passkey_registration!/1 returns the passkey_registration with given id" do
      passkey_registration = passkey_registration_fixture()
      assert Passkeys.get_passkey_registration!(passkey_registration.id) == passkey_registration
    end

    test "create_passkey_registration/1 with valid data creates a passkey_registration" do
      valid_attrs = %{state: "some state", user_id: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %PasskeyRegistration{} = passkey_registration} = Passkeys.create_passkey_registration(valid_attrs)
      assert passkey_registration.state == "some state"
      assert passkey_registration.user_id == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_passkey_registration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Passkeys.create_passkey_registration(@invalid_attrs)
    end

    test "update_passkey_registration/2 with valid data updates the passkey_registration" do
      passkey_registration = passkey_registration_fixture()
      update_attrs = %{state: "some updated state", user_id: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %PasskeyRegistration{} = passkey_registration} = Passkeys.update_passkey_registration(passkey_registration, update_attrs)
      assert passkey_registration.state == "some updated state"
      assert passkey_registration.user_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_passkey_registration/2 with invalid data returns error changeset" do
      passkey_registration = passkey_registration_fixture()
      assert {:error, %Ecto.Changeset{}} = Passkeys.update_passkey_registration(passkey_registration, @invalid_attrs)
      assert passkey_registration == Passkeys.get_passkey_registration!(passkey_registration.id)
    end

    test "delete_passkey_registration/1 deletes the passkey_registration" do
      passkey_registration = passkey_registration_fixture()
      assert {:ok, %PasskeyRegistration{}} = Passkeys.delete_passkey_registration(passkey_registration)
      assert_raise Ecto.NoResultsError, fn -> Passkeys.get_passkey_registration!(passkey_registration.id) end
    end

    test "change_passkey_registration/1 returns a passkey_registration changeset" do
      passkey_registration = passkey_registration_fixture()
      assert %Ecto.Changeset{} = Passkeys.change_passkey_registration(passkey_registration)
    end
  end
end
