use chrono::{DateTime, Utc};
use sqlx::{types::Json, Pool, Postgres};
use uuid::Uuid;
use webauthn_rs::prelude::*;
use webauthn_rs_proto::PublicKeyCredentialCreationOptions;

#[derive(sqlx::FromRow)]
pub(crate) struct Registration {
    pub(crate) id: Uuid,
    user_id: Uuid,
    reg_state: Json<PasskeyRegistration>,
    pub(crate) expires_at: DateTime<Utc>,
    confirmed_at: Option<DateTime<Utc>>,
    created_at: Option<DateTime<Utc>>,
    updated_at: Option<DateTime<Utc>>,
}

impl Registration {
    pub(crate) async fn create_passkey_registration(
        pool: Pool<Postgres>,
        user_id: Uuid,
        user_name: &str,
        user_display_name: &str,
    ) -> Result<(PublicKeyCredentialCreationOptions, Self), ()> {
        let rp_id = "localhost";
        let rp_origin = Url::parse("http://localhost").map_err(|_| ())?;

        let builder = WebauthnBuilder::new(rp_id, &rp_origin).map_err(|_| ())?;

        let webauthn = builder.build().map_err(|_| ())?;

        match webauthn.start_passkey_registration(user_id, user_name, user_display_name, None) {
            Ok((credential_creation_options, reg_state)) => {
                match sqlx::query_as!(
                    Registration,
                    r#"
                    insert into registrations(user_id, reg_state, expires_at)
                    values ($1, $2, $3)
                    returning id, user_id, reg_state as "reg_state: Json<PasskeyRegistration>", expires_at, confirmed_at, created_at, updated_at
                   "#,
                    user_id,
                    Json(reg_state) as _,
                    Utc::now() + chrono::Duration::minutes(60),
                )
                .fetch_one(&pool)
                .await {
                    Ok(registration) => Ok((credential_creation_options.public_key, registration)),
                    Err(_) => return Err(()),
                }
            }
            Err(_) => Err(()),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{
        config::Settings,
        db::{create_pool, migrate},
    };

    #[tokio::test]
    async fn create_passkey_registration() {
        let settings = Settings::from_env();
        migrate(&settings).await;
        let pool = create_pool(&settings).await;

        let (_ccr, registration) = Registration::create_passkey_registration(
            pool,
            Uuid::new_v4(),
            "test_user",
            "Test User",
        )
        .await
        .unwrap();

        assert_eq!(registration.user_id, registration.user_id);
    }
}
