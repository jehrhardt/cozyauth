use std::sync::Arc;

use uuid::Uuid;
use webauthn_rs::{WebauthnBuilder, prelude::{Url, PasskeyRegistration, CreationChallengeResponse}};


pub(crate) struct RelyingParty {
    pub(crate) name: String,
    pub(crate) origin: String,
}

pub(crate) struct User {
    pub(crate) id: Uuid,
    pub(crate) name: String,
    pub(crate) display_name: String,
}

pub(crate) fn start_registration(relying_party: RelyingParty, user: User) -> (CreationChallengeResponse, Arc<PasskeyRegistration>) {
    let rp_origin = Url::parse(&relying_party.origin).unwrap();
    let rp_id = rp_origin.domain().unwrap();
    let webauthn = match WebauthnBuilder::new(rp_id, &rp_origin) {
        Ok(builder) => builder.rp_name(&relying_party.name).build().unwrap(),
        Err(e) => panic!("Error: {}", e),
    };
    match webauthn.start_passkey_registration(user.id, &user.name, &user.display_name, None) {
        Ok((ccr, skr)) => {
            (ccr, Arc::new(skr))
        },
        Err(e) => panic!("Error: {}", e),

    }
}
