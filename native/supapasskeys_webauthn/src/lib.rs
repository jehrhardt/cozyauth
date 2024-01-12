use rustler::{NifResult, NifStruct};
use uuid::Uuid;
use webauthn_rs::{
    prelude::{PasskeyRegistration, RegisterPublicKeyCredential, Url},
    Webauthn,
};

#[derive(NifStruct)]
#[module = "Supapasskeys.WebAuthn.RelyingParty"]
struct RelyingParty<'a> {
    name: &'a str,
    origin: &'a str,
}

#[derive(NifStruct)]
#[module = "Supapasskeys.WebAuthn.User"]
struct User<'a> {
    id: &'a str,
    name: &'a str,
    display_name: &'a str,
}

#[rustler::nif]
fn start_passkey_registration(
    user: User,
    relying_party: RelyingParty,
) -> NifResult<(String, String)> {
    let webauthn = init_webauthn(relying_party);
    let user_id = Uuid::parse_str(user.id).unwrap();
    let (creation_challenge, state) = webauthn
        .start_passkey_registration(user_id, user.name, user.display_name, None)
        .unwrap();
    Ok((
        serde_json::to_string(&creation_challenge.public_key).unwrap(),
        serde_json::to_string(&state).unwrap(),
    ))
}

#[rustler::nif]
fn finish_passkey_registration(
    public_key_credential_json: &str,
    state_json: &str,
    relying_party: RelyingParty,
) -> NifResult<String> {
    let webauthn = init_webauthn(relying_party);
    let public_key_credentials =
        serde_json::from_str::<RegisterPublicKeyCredential>(public_key_credential_json).unwrap();
    let state = serde_json::from_str::<PasskeyRegistration>(state_json).unwrap();
    let passkey = webauthn
        .finish_passkey_registration(&public_key_credentials, &state)
        .unwrap();
    Ok(serde_json::to_string(&passkey).unwrap())
}

fn init_webauthn(relying_party: RelyingParty) -> Webauthn {
    let relying_party_url = Url::parse(relying_party.origin).unwrap();
    let relying_party_id = relying_party_url.domain().unwrap();
    webauthn_rs::WebauthnBuilder::new(relying_party_id, &relying_party_url)
        .map(|builder| builder.rp_name(relying_party.name))
        .unwrap()
        .build()
        .unwrap()
}

rustler::init!(
    "Elixir.Supapasskeys.WebAuthn",
    [start_passkey_registration, finish_passkey_registration]
);
