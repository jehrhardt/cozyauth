// Copyright 2024 Cozy Auth Contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
