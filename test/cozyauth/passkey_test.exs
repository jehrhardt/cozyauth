defmodule Cozyauth.PasskeysTest do
  use ExUnit.Case

  import Cozyauth.Passkeys

  test "start passkey registration" do
    user_id = Faker.UUID.v4()
    user_name = Faker.Internet.user_name()
    user_display_name = Faker.Person.name()

    {:ok, credential_creation_options} =
      start_passkey_registration(user_id, user_name, user_display_name)
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
end
