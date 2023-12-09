use std::time::Duration;

use axum::{
    extract::{Path, State},
    routing::post,
    Json, Router,
};
use serde_json::{json, Value};
use sqlx::{postgres::PgPoolOptions, PgPool};
use uuid::Uuid;
use webauthn_rs_proto::{RegisterPublicKeyCredential, PublicKeyCredentialCreationOptions};

use crate::types::User;

mod db;
mod passkeys;
mod types;

async fn start_passkey_registration(
    State(pool): State<PgPool>,
    Json(user): Json<User>,
) -> Json<PublicKeyCredentialCreationOptions> {
    let mut conn = pool.acquire().await.unwrap();
    let relying_party = db::get_relying_party(&mut conn).unwrap();
    let (ccr, skr) = passkeys::start_registration(relying_party, user.clone());
    db::new_passkey_registration(&mut conn, user.id, skr)
        .await
        .unwrap();
    Json(ccr.public_key)
}

async fn finish_passkey_registration(
    State(pool): State<PgPool>,
    Path(user_id): Path<Uuid>,
    Json(reg): Json<RegisterPublicKeyCredential>,
) -> Json<Value> {
    let mut conn = pool.acquire().await.unwrap();
    let relying_party = db::get_relying_party(&mut conn).unwrap();
    let state = db::get_passkey_registration(&mut conn, user_id)
        .await
        .unwrap();
    let passkey = passkeys::finish_registration(relying_party, reg, state);
    let message = format!("Passkey {} registered ✅", passkey.cred_id());
    Json(json!({ "ok": message }))
}

#[tokio::main]
async fn main() {
    let db_connection_str = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgres://postgres:postgres@localhost/supapasskeys".to_string());

    // set up connection pool
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .acquire_timeout(Duration::from_secs(3))
        .connect(&db_connection_str)
        .await
        .expect("can't connect to database");

    let app = Router::new()
        .route("/", post(start_passkey_registration))
        .route("/:user_id", post(finish_passkey_registration))
        .with_state(pool);

    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000")
        .await
        .unwrap();
    println!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}
