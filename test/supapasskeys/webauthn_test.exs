defmodule Supapasskeys.WebAuthnTest do
  use ExUnit.Case

  alias Supapasskeys.WebAuthn

  describe "WebAuthn" do
    test "start_passkey_registration/2 returns credentials creation options" do
      relying_party_domain = Faker.Internet.domain_name()

      relying_party =
        %WebAuthn.RelyingParty{
          name: Faker.Company.name(),
          origin: "https://#{relying_party_domain}"
        }

      user =
        %WebAuthn.User{
          id: Faker.UUID.v4(),
          name: Faker.Internet.email(),
          display_name: Faker.Person.name()
        }

      {credentials_creation_options, state} =
        WebAuthn.start_passkey_registration(user, relying_party)

      %{
        "rp" => %{
          "name" => relying_party_name,
          "id" => relying_party_id
        },
        "user" => %{
          "name" => user_name,
          "displayName" => user_display_name,
          "id" => user_id
        },
        "challenge" => challenge,
        "pubKeyCredParams" => [
          %{"type" => "public-key", "alg" => -7},
          %{"type" => "public-key", "alg" => -257}
        ],
        "timeout" => 60000,
        "attestation" => "none",
        "authenticatorSelection" => %{
          "requireResidentKey" => false,
          "userVerification" => "preferred"
        },
        "extensions" => %{"uvm" => true, "credProps" => true}
      } = Jason.decode!(credentials_creation_options)

      assert relying_party_name == relying_party.name
      assert relying_party_id == relying_party_domain
      assert user_name == user.name
      assert user_display_name == user.display_name

      assert user_id ==
               UUID.string_to_binary!(user.id)
               |> Base.url_encode64(padding: false)

      assert is_binary(challenge)

      assert Base.url_decode64!(challenge, padding: false)
             |> byte_size() == 32

      assert is_binary(state)
    end
  end
end
