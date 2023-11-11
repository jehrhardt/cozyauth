use std::str::FromStr;

use webauthn_rs::prelude::*;

use thiserror::Error;

#[derive(rustler::NifStruct)]
#[module = "Supapasskeys.WebAuthn.RelyingParty"]
struct RelyingParty<'a> {
    id: &'a str,
    name: &'a str,
    origin: &'a str,
}

#[derive(rustler::NifStruct)]
#[module = "Supapasskeys.WebAuthn.User"]
struct User<'a> {
    id: &'a str,
    name: &'a str,
    display_name: &'a str,
}

#[derive(rustler::NifStruct)]
#[module = "Supapasskeys.WebAuthn.RegistrationRequest"]
struct RegistrationRequest {
    creation_options_json: String,
    passkey_registration: PasskeyRegistration,
}

struct PasskeyRegistration {
    data: Vec<u8>,
}

impl rustler::Encoder for PasskeyRegistration {
    fn encode<'a>(&self, env: rustler::Env<'a>) -> rustler::Term<'a> {
        let src = self.data.as_slice();
        let mut binary = rustler::OwnedBinary::new(src.len()).unwrap();
        binary.as_mut_slice().copy_from_slice(src);
        rustler::Binary::from_owned(binary, env).encode(env)
    }
}

impl<'a> rustler::Decoder<'a> for PasskeyRegistration {
    fn decode(term: rustler::Term<'a>) -> Result<Self, rustler::Error> {
        let binary: rustler::Binary<'a> = term.decode()?;
        Ok(PasskeyRegistration {
            data: binary.to_vec(),
        })
    }
}

#[derive(Error, Debug)]
pub enum PasskeyError {
    #[error("Origin is not a valid URL")]
    OriginUrl,

    #[error("User ID is not a valid UUID")]
    UserUuid,

    #[error("Failed to create builder")]
    Builder,

    #[error("Failed to initialize Webauthn")]
    Webauthn,

    #[error("Failed to serialize creation options")]
    SerializeCreationOptions,

    #[error("Failed to serialize Passkey registration")]
    SerializePasskeyRegistration,
}

impl rustler::Encoder for PasskeyError {
    fn encode<'a>(&self, env: rustler::Env<'a>) -> rustler::Term<'a> {
        format!("{self}").encode(env)
    }
}

#[rustler::nif]
fn start_passkey_registration<'a>(
    relying_party: RelyingParty<'a>,
    user: User<'a>,
) -> Result<RegistrationRequest, PasskeyError> {
    let rp_id = relying_party.id;
    let rp_name = relying_party.name;

    match Url::parse(relying_party.origin) {
        Ok(rp_origin) => match WebauthnBuilder::new(rp_id, &rp_origin) {
            Ok(builder) => match builder.rp_name(rp_name).build() {
                Ok(webauthn) => match Uuid::from_str(user.id) {
                    Ok(user_unique_id) => match webauthn.start_passkey_registration(
                        user_unique_id,
                        user.name,
                        user.display_name,
                        None,
                    ) {
                        Ok((ccr, skr)) => match serde_json::to_string(&ccr.public_key) {
                            Ok(creation_options_json) => match serde_cbor::to_vec(&skr) {
                                Ok(data) => {
                                    let passkey_registration = PasskeyRegistration { data };
                                    Ok(RegistrationRequest {
                                        creation_options_json,
                                        passkey_registration,
                                    })
                                }
                                Err(_e) => Err(PasskeyError::SerializePasskeyRegistration),
                            },
                            Err(_e) => Err(PasskeyError::SerializeCreationOptions),
                        },
                        Err(_e) => Err(PasskeyError::Webauthn),
                    },
                    Err(_e) => Err(PasskeyError::UserUuid),
                },
                Err(_e) => Err(PasskeyError::Webauthn),
            },
            Err(_e) => Err(PasskeyError::Builder),
        },
        Err(_e) => Err(PasskeyError::OriginUrl),
    }
}

rustler::init!("Elixir.Supapasskeys.WebAuthn", [start_passkey_registration]);
