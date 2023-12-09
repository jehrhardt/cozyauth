use webauthn_rs::{
    prelude::{CreationChallengeResponse, Passkey, PasskeyRegistration, Url, WebauthnError},
    Webauthn, WebauthnBuilder,
};
use webauthn_rs_proto::RegisterPublicKeyCredential;

use crate::types::{RelyingParty, User};

pub(crate) fn start_registration(
    relying_party: RelyingParty,
    user: User,
) -> (CreationChallengeResponse, PasskeyRegistration) {
    let webauthn = init_webauthn(&relying_party).unwrap();
    match webauthn.start_passkey_registration(user.id, &user.name, &user.display_name, None) {
        Ok((ccr, skr)) => (ccr, skr),
        Err(e) => panic!("Error: {}", e),
    }
}

pub(crate) fn finish_registration(
    relying_party: RelyingParty,
    reg: RegisterPublicKeyCredential,
    state: PasskeyRegistration,
) -> Passkey {
    let webauthn = init_webauthn(&relying_party).unwrap();
    match webauthn.finish_passkey_registration(&reg, &state) {
        Ok(passkey) => passkey,
        Err(e) => panic!("Error: {}", e),
    }
}

fn init_webauthn(relying_party: &RelyingParty) -> Result<Webauthn, WebauthnError> {
    let rp_origin = Url::parse(&relying_party.origin).unwrap();
    let rp_id = rp_origin.domain().unwrap();
    WebauthnBuilder::new(rp_id, &rp_origin)
        .map(|builder| builder.rp_name(&relying_party.name).build())
        .unwrap()
}
