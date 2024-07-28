use chrono::{DateTime, Utc};
use sqlx::{prelude::FromRow, types::Json, PgPool};
use uuid::Uuid;
use webauthn_rs::prelude::PasskeyRegistration;
use webauthn_rs_proto::{PublicKeyCredentialCreationOptions, RegisterPublicKeyCredential};

use super::{passkey::Passkey, webauthn_utils};

#[derive(Debug, FromRow)]
pub(crate) struct Registration {
    pub(crate) id: Uuid,
    pub(crate) user_id: Uuid,
    reg_state: Json<PasskeyRegistration>,
    pub(crate) expires_at: DateTime<Utc>,
}

#[derive(thiserror::Error, Debug)]
pub(crate) enum RegistrationError {
    #[error("Relying party initialization error")]
    RelyingPartyInit(#[from] webauthn_utils::WebauthnInitError),
    #[error("Registration not found")]
    NotFound(#[from] sqlx::Error),
    #[error("Unable to start Passkey registration: {0}")]
    PasskeyStart(webauthn_rs::prelude::WebauthnError),
    #[error("Unable to finish Passkey registration: {0}")]
    PasskeyFinish(webauthn_rs::prelude::WebauthnError),
    #[error("SQL error")]
    Sqlx(sqlx::Error),
    #[error("UnknownError")]
    Unknown,
}

impl Registration {
    pub(crate) async fn create_passkey_registration(
        pool: &PgPool,
        user_id: Uuid,
        user_name: &str,
        user_display_name: &str,
    ) -> Result<(PublicKeyCredentialCreationOptions, Self), RegistrationError> {
        match webauthn_utils::init() {
            Ok(webauthn) => {
                match webauthn.start_passkey_registration(user_id, user_name, user_display_name, None) {
                Ok((credential_creation_options, reg_state)) => {
                    match sqlx::query_as!(
                        Registration,
                        r#"
                        insert into registrations(user_id, reg_state, expires_at)
                        values ($1, $2, $3)
                        returning id, user_id, reg_state as "reg_state: Json<webauthn_rs::prelude::PasskeyRegistration>", expires_at
                        "#,
                        user_id,
                        Json(reg_state) as _,
                        Utc::now() + chrono::Duration::minutes(60),
                    )
                    .fetch_one(pool)
                    .await
                    {
                        Ok(registration) => Ok((credential_creation_options.public_key, registration)),
                        Err(e) => Err(RegistrationError::Sqlx(e)),
                    }
                }
                Err(e) => Err(RegistrationError::PasskeyStart(e)),
            }
            }
            Err(e) => Err(e.into()),
        }
    }

    pub(crate) async fn find_unconfirmed_by_id(
        pool: &PgPool,
        id: Uuid,
    ) -> Result<Self, RegistrationError> {
        sqlx::query_as!(
            Registration,
            r#"
            select id, user_id, reg_state as "reg_state: Json<webauthn_rs::prelude::PasskeyRegistration>", expires_at
            from registrations
            where id = $1 and confirmed_at is null
            "#,
            id
        )
        .fetch_one(pool)
        .await.map_err(|e| e.into())
    }

    pub(crate) async fn confirm(
        &self,
        pool: &PgPool,
        credential: &RegisterPublicKeyCredential,
    ) -> Result<(), RegistrationError> {
        match webauthn_utils::init() {
            Ok(webauthn) => {
                match webauthn.finish_passkey_registration(credential, &self.reg_state) {
                    Ok(passkey) => match pool.begin().await {
                        Ok(mut tx) => {
                            match Passkey::create(&mut tx, &self.user_id, passkey).await {
                                Ok(Passkey { id }) => {
                                    match self.mark_confirmed(&mut tx, &id).await {
                                        Ok(_) => tx.commit().await?,
                                        Err(_) => tx.rollback().await?,
                                    }
                                    Ok(())
                                }
                                Err(_) => {
                                    tx.rollback().await?;
                                    Err(RegistrationError::Unknown)
                                }
                            }
                        }
                        Err(_) => Err(RegistrationError::Unknown),
                    },
                    Err(e) => Err(RegistrationError::PasskeyFinish(e)),
                }
            }
            Err(e) => Err(e.into()),
        }
    }

    async fn mark_confirmed(
        &self,
        tx: &mut sqlx::Transaction<'_, sqlx::Postgres>,
        passkey_id: &Uuid,
    ) -> Result<(), RegistrationError> {
        sqlx::query!(
            r#"
            update registrations
            set confirmed_at = now(), passkey_id = $2
            where id = $1 and confirmed_at is null
            "#,
            self.id,
            passkey_id
        )
        .execute(&mut **tx)
        .await
        .map_err(|e| e.into())
        .map(|_| ())
    }
}
