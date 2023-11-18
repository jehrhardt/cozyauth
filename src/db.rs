use rocket_db_pools::sqlx;
use sqlx::{query, Error, PgConnection, Row};
use uuid::Uuid;
use webauthn_rs::prelude::PasskeyRegistration;

use crate::types::RelyingParty;

pub(crate) fn get_relying_party(_db: &mut PgConnection) -> Result<RelyingParty, Error> {
    Ok(RelyingParty {
        name: "Supapasskeys".to_string(),
        origin: "http://localhost:8000".to_string(),
    })
}

pub(crate) async fn new_passkey_registration(
    db: &mut PgConnection,
    user_id: Uuid,
    state: PasskeyRegistration,
) -> Result<(), Error> {
    let state_cbor = serde_cbor::to_vec(&state).unwrap();
    let _ = query("INSERT INTO passkey_registrations (user_id, state) VALUES ($1, $2)")
        .bind(user_id)
        .bind(&state_cbor)
        .execute(db)
        .await;
    Ok(())
}

pub(crate) async fn get_passkey_registration(
    db: &mut PgConnection,
    user_id: Uuid,
) -> Result<PasskeyRegistration, Error> {
    query("SELECT state FROM passkey_registrations WHERE user_id = $1")
        .bind(user_id)
        .fetch_one(db)
        .await
        .map(|row| row.get::<Vec<u8>, _>("state"))
        .map(|state_cbor| serde_cbor::from_slice(&state_cbor).unwrap())
}
