// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use axum::extract::FromRef;
use sqlx::{postgres::PgPoolOptions, Pool, Postgres};

#[derive(Clone)]
pub struct Context {
    pub(crate) passkeys_context: cozyauth_passkeys::Context,
}

impl Context {
    pub fn new() -> Self {
        let relying_party = cozyauth_passkeys::RelyingParty {
            domain: "https://example.com".to_string(),
            name: None,
        };
        let passkeys_context = cozyauth_passkeys::Context { relying_party };
        Context { passkeys_context }
    }
}

impl FromRef<Context> for cozyauth_passkeys::Context {
    fn from_ref(context: &Context) -> Self {
        context.passkeys_context.clone()
    }
}
