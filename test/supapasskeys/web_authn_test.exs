defmodule Supapasskeys.WebAuthnTest do
  use ExUnit.Case
  alias Supapasskeys.WebAuthn.RegistrationRequest
  alias Supapasskeys.WebAuthn.RelyingParty
  alias Supapasskeys.WebAuthn.User
  import Supapasskeys.WebAuthn

  setup do
    domain = Faker.Internet.domain_name()
    company_name = Faker.Company.name()
    relying_party = %RelyingParty{id: domain, name: company_name, origin: "https://#{domain}"}
    user_id = UUID.uuid4()
    user_name = Faker.Internet.user_name()
    display_name = Faker.Person.name()
    user = %User{id: user_id, name: user_name, display_name: display_name}

    {:ok, %{relying_party: relying_party, user: user}}
  end

  test "start_passkey_registration", %{relying_party: relying_party, user: user} do
    {:ok,
     %RegistrationRequest{
       creation_options_json: creation_options_json,
       passkey_registration: passkey_registration
     }} =
      start_passkey_registration(
        relying_party,
        user
      )

    %{
      "rp" => %{
        "id" => rp_id,
        "name" => rp_name
      },
      "user" => %{
        "id" => user_id,
        "name" => user_name,
        "displayName" => display_name
      },
      "challenge" => challenge,
      "pubKeyCredParams" => pub_key_cred_params,
      "timeout" => 60000,
      "attestation" => "none",
      "authenticatorSelection" => %{
        "requireResidentKey" => false,
        "userVerification" => "preferred"
      },
      "extensions" => %{"credProps" => true, "uvm" => true}
    } = Jason.decode!(creation_options_json)

    assert rp_id == relying_party.id
    assert rp_name == relying_party.name
    assert user_name == user.name
    assert display_name == user.display_name
    assert user_id == user.id |> UUID.string_to_binary!() |> Base.url_encode64(padding: false)

    assert 32 == Base.url_decode64!(challenge, padding: false) |> byte_size()

    assert pub_key_cred_params == [
             %{"alg" => -7, "type" => "public-key"},
             %{"alg" => -257, "type" => "public-key"}
           ]

    assert is_binary(passkey_registration)
  end
end
