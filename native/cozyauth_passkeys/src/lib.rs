use std::str::FromStr;

use webauthn_rs::prelude::*;

#[derive(Debug, rustler::NifStruct)]
#[module = "Cozyauth.Passkeys.RelyingParty"]
struct RelyingParty {
    domain: String,
    name: String,
}

#[derive(Debug, rustler::NifStruct)]
#[module = "Cozyauth.Passkeys.User"]
struct User {
    id: String,
    name: String,
    display_name: String,
}

#[rustler::nif]
fn start_passkey_registration(
    user: User,
    relying_party: RelyingParty,
) -> rustler::NifResult<String> {
    match Url::parse(relying_party.domain.as_str()) {
        Ok(rp_origin) => {
            let rp_id = rp_origin.domain().unwrap();
            let builder = WebauthnBuilder::new(rp_id, &rp_origin).expect("Invalid configuration");
            let webauthn = builder.build().expect("Invalid configuration");

            match Uuid::from_str(user.id.as_str()) {
                Ok(user_unique_id) => {
                    let user_name = user.name.as_str();
                    let user_display_name = user.display_name.as_str();
                    match webauthn.start_passkey_registration(
                        user_unique_id,
                        user_name,
                        user_display_name,
                        None,
                    ) {
                        Ok((ccr, _skr)) => match serde_json::to_string(&ccr) {
                            Ok(options) => Ok(options),
                            Err(_) => {
                                Err(rustler::Error::Term(Box::new("JSON serialization failed")))
                            }
                        },
                        Err(WebauthnError::InvalidUsername) => {
                            Err(rustler::Error::Term(Box::new("invalid user name")))
                        }
                        Err(_) => Err(rustler::Error::Term(Box::new(
                            "failed to start Passkey registration",
                        ))),
                    }
                }
                Err(_) => Err(rustler::Error::Term(Box::new("user ID must be UUID"))),
            }
        }
        Err(_) => Err(rustler::Error::Term(Box::new("invalid domain"))),
    }
}

rustler::init!("Elixir.Cozyauth.Passkeys", [start_passkey_registration]);
