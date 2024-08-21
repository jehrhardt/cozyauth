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

use sqlx::types::Json;
use sqlx::FromRow;
use uuid::Uuid;
use webauthn_rs::prelude::Credential;

#[derive(Debug, FromRow)]
pub(crate) struct Passkey {
    pub(crate) id: Uuid,
}
impl Passkey {
    pub(crate) async fn create(
        tx: &mut sqlx::Transaction<'_, sqlx::Postgres>,
        user_id: &Uuid,
        passkey: webauthn_rs::prelude::Passkey,
    ) -> Result<Self, sqlx::Error> {
        let credential: Credential = passkey.into();
        sqlx::query_as!(
            Passkey,
            r#"
            insert into passkeys (user_id, credential)
            values ($1, $2)
            returning id
            "#,
            user_id,
            Json(credential) as _
        )
        .fetch_one(&mut **tx)
        .await
    }
}
