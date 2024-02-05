defmodule Supapasskeys.PasskeysTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration

  describe "registrations" do
    import Supapasskeys.SupabaseFixtures
    import Supapasskeys.PasskeysFixtures

    setup do
      project = project_fixture()
      relying_party = relying_party_fixture(project)

      {:ok,
       %{
         relying_party: relying_party,
         project: project
       }}
    end

    test "get_registration!/1 returns the registration with given id", %{
      relying_party: relying_party,
      project: project
    } do
      registration = registration_fixture(project, relying_party)
      assert Passkeys.get_registration!(project, registration.id) == registration
    end

    test "create_registration/1 with valid data creates a registration", %{
      relying_party: relying_party,
      project: project
    } do
      valid_attrs = %{
        id: Faker.UUID.v4(),
        name: Faker.Internet.email(),
        display_name: Faker.Person.name()
      }

      assert {:ok, %Registration{} = registration} =
               Passkeys.create_registration(project, relying_party, valid_attrs)

      assert is_binary(registration.state)
      assert registration.user_id == valid_attrs.id
      assert is_binary(registration.creation_options)
    end

    test "create_registration/1 with invalid data returns error changeset", %{
      relying_party: relying_party,
      project: project
    } do
      invalid_attrs = %{state: nil, user_id: nil}

      assert {:error, %Ecto.Changeset{}} =
               Passkeys.create_registration(project, relying_party, invalid_attrs)
    end

    test "update_registration/2 with valid data updates the registration", %{
      relying_party: relying_party,
      project: project
    } do
      registration = registration_fixture(project, relying_party)
      update_state_json = Jason.encode!(%{"some" => "updated state"})
      update_attrs = %{state: update_state_json, user_id: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Registration{} = registration} =
               Passkeys.update_registration(project, registration, update_attrs)

      assert registration.state == update_state_json
      assert registration.user_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_registration/2 with invalid data returns error changeset", %{
      relying_party: relying_party,
      project: project
    } do
      registration = registration_fixture(project, relying_party)
      invalid_attrs = %{state: nil, user_id: nil}

      assert {:error, %Ecto.Changeset{}} =
               Passkeys.update_registration(project, registration, invalid_attrs)

      assert registration == Passkeys.get_registration!(project, registration.id)
    end
  end

  describe "relying_parties" do
    alias Supapasskeys.Passkeys.RelyingParty
    import Supapasskeys.SupabaseFixtures
    import Supapasskeys.PasskeysFixtures

    setup do
      {:ok, %{project: project_fixture()}}
    end

    test "list_relying_parties/0 returns all relying_parties", %{project: project} do
      relying_party = relying_party_fixture(project)
      assert Passkeys.list_relying_parties(project) == [relying_party]
    end

    test "get_relying_party!/1 returns the relying_party with given id", %{project: project} do
      relying_party = relying_party_fixture(project)
      assert Passkeys.get_relying_party!(project, relying_party.id) == relying_party
    end

    test "create_relying_party/1 with valid data creates a relying_party", %{project: project} do
      valid_attrs = %{
        name: Faker.Internet.email(),
        origin: "https://#{Faker.Internet.domain_name()}"
      }

      assert {:ok, %RelyingParty{} = _relying_party} =
               Passkeys.create_relying_party(project, valid_attrs)
    end

    test "create_relying_party/1 with invalid data returns error changeset", %{project: project} do
      invalid_attrs = %{name: nil, origin: nil}
      assert {:error, %Ecto.Changeset{}} = Passkeys.create_relying_party(project, invalid_attrs)
    end

    test "update_relying_party/2 with valid data updates the relying_party", %{project: project} do
      relying_party = relying_party_fixture(project)
      update_attrs = %{}

      assert {:ok, %RelyingParty{} = _relying_party} =
               Passkeys.update_relying_party(project, relying_party, update_attrs)
    end

    test "update_relying_party/2 with invalid data returns error changeset", %{project: project} do
      relying_party = relying_party_fixture(project)
      invalid_attrs = %{name: nil, origin: nil}

      assert {:error, %Ecto.Changeset{}} =
               Passkeys.update_relying_party(project, relying_party, invalid_attrs)

      assert relying_party == Passkeys.get_relying_party!(project, relying_party.id)
    end

    test "delete_relying_party/1 deletes the relying_party", %{project: project} do
      relying_party = relying_party_fixture(project)
      assert {:ok, %RelyingParty{}} = Passkeys.delete_relying_party(project, relying_party)

      assert_raise Ecto.NoResultsError, fn ->
        Passkeys.get_relying_party!(project, relying_party.id)
      end
    end

    test "change_relying_party/1 returns a relying_party changeset", %{project: project} do
      relying_party = relying_party_fixture(project)
      assert %Ecto.Changeset{} = Passkeys.change_relying_party(relying_party)
    end
  end
end
