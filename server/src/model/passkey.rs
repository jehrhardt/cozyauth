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
