use chrono::{DateTime, Utc};
use sqlx::{types::Json, PgPool};
use uuid::Uuid;
use webauthn_rs::prelude::*;
use webauthn_rs_proto::PublicKeyCredentialCreationOptions;

#[derive(sqlx::FromRow)]
pub(crate) struct Registration {
    pub(crate) id: Uuid,
    reg_state: Json<PasskeyRegistration>,
    pub(crate) expires_at: DateTime<Utc>,
}

impl Registration {
    pub(crate) async fn create_passkey_registration(
        pool: &PgPool,
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
                    returning id, reg_state as "reg_state: Json<PasskeyRegistration>", expires_at
                   "#,
                    user_id,
                    Json(reg_state) as _,
                    Utc::now() + chrono::Duration::minutes(60),
                )
                .fetch_one(pool)
                .await
                {
                    Ok(registration) => Ok((credential_creation_options.public_key, registration)),
                    Err(_) => Err(()),
                }
            }
            Err(_) => Err(()),
        }
    }

    pub(crate) async fn find_unconfirmed_by_id(
        pool: &PgPool,
        id: Uuid,
    ) -> Result<Self, sqlx::Error> {
        sqlx::query_as!(
            Registration,
            r#"
            select id, reg_state as "reg_state: Json<PasskeyRegistration>", expires_at
            from registrations
            where id = $1 and confirmed_at is null
            "#,
            id
        )
        .fetch_one(pool)
        .await
    }

    pub(crate) async fn confirm(
        &self,
        pool: &PgPool,
        credential: &RegisterPublicKeyCredential,
    ) -> Result<Self, ()> {
        let rp_id = "localhost";
        let rp_origin = Url::parse("http://localhost").map_err(|_| ())?;

        let builder = WebauthnBuilder::new(rp_id, &rp_origin).map_err(|_| ())?;
        let webauthn = builder.build().map_err(|_| ())?;

        match webauthn.finish_passkey_registration(credential, &self.reg_state) {
            Ok(_) => {
                match sqlx::query_as!(
                    Registration,
                    r#"
                    update registrations
                    set confirmed_at = now()
                    where id = $1
                    returning id, reg_state as "reg_state: Json<PasskeyRegistration>", expires_at
                    "#,
                    self.id,
                )
                .fetch_one(pool)
                .await
                {
                    Ok(registration) => Ok(registration),
                    Err(_) => Err(()),
                }
            }
            Err(_) => Err(()),
        }
    }
}
