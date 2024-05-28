defmodule Cozyauth.PasskeysTest do
  alias Cozyauth.Passkeys.RelyingParty
  alias Cozyauth.Passkeys.User
  use ExUnit.Case

  import Cozyauth.Passkeys

  setup do
    relying_party = %RelyingParty{
      domain: "https://#{Faker.Internet.domain_name()}",
      name: Faker.Company.name()
    }

    [relying_party: relying_party]
  end

  test "start passkey registration", %{relying_party: relying_party} do
    user_id = Faker.UUID.v4()
    user_name = Faker.Internet.user_name()
    user_display_name = Faker.Person.name()

    {:ok, credential_creation_options} =
      %User{id: user_id, name: user_name, display_name: user_display_name}
      |> start_passkey_registration(relying_party)
      |> Jason.decode()

    assert %{
             "publicKey" => %{
               "user" => %{
                 "id" => user_id_base64,
                 "name" => ^user_name,
                 "displayName" => ^user_display_name
               }
             }
           } = credential_creation_options

    assert user_id_base64 |> Base.url_decode64!(padding: false) |> Ecto.UUID.load!() == user_id
  end

  test "start passkey registration with non-UUID user ID", %{relying_party: relying_party} do
    user_id = "foo"
    user_name = Faker.Internet.user_name()
    user_display_name = Faker.Person.name()

    {:error, "user ID must be UUID"} =
      %User{id: user_id, name: user_name, display_name: user_display_name}
      |> start_passkey_registration(relying_party)
  end

  test "start passkey registration without username", %{relying_party: relying_party} do
    user_id = Faker.UUID.v4()
    user_name = ""
    user_display_name = Faker.Person.name()

    {:error, "invalid user name"} =
      %User{id: user_id, name: user_name, display_name: user_display_name}
      |> start_passkey_registration(relying_party)
  end
end
