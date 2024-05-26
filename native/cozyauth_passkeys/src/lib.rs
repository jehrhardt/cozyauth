use std::str::FromStr;

use webauthn_rs::prelude::*;

#[rustler::nif]
fn start_passkey_registration(
    user_id: String,
    user_name: String,
    user_display_name: String,
) -> rustler::NifResult<String> {
    let rp_id = "example.com";
    let rp_origin = Url::parse("https://idm.example.com").expect("Invalid URL");
    let builder = WebauthnBuilder::new(rp_id, &rp_origin).expect("Invalid configuration");
    let webauthn = builder.build().expect("Invalid configuration");

    let (ccr, _skr) = webauthn
        .start_passkey_registration(
            Uuid::from_str(user_id.as_str()).expect("User ID is not a UUID"),
            user_name.as_str(),
            user_display_name.as_str(),
            None,
        )
        .expect("Failed to start registration.");

    match serde_json::to_string(&ccr) {
        Ok(options) => Ok(options),
        Err(_) => Err(rustler::Error::Atom("JSON serialization failed")),
    }
}

rustler::init!("Elixir.Cozyauth.Passkeys", [start_passkey_registration]);
