use url::Url;
use webauthn_rs::prelude::*;

#[derive(Debug, thiserror::Error)]
pub(crate) enum WebauthnInitError {
    #[error("Incorrect URL")]
    Origin(#[from] url::ParseError),
    #[error("No domain found in URL `{0}`")]
    RelyingPartyId(String),
    #[error("Webauthn can not be initialized")]
    Webauthn(#[from] WebauthnError),
}

pub(super) fn init(rp_origin: &Url) -> Result<Webauthn, WebauthnInitError> {
    match rp_origin.host_str() {
        Some(rp_id) => WebauthnBuilder::new(rp_id, rp_origin)
            .and_then(|b| b.build())
            .map_err(|e| e.into()),
        None => Err(WebauthnInitError::RelyingPartyId(rp_origin.to_string())),
    }
}
