use std::time::Duration;

use axum::{routing::post, Router};
use sqlx::postgres::PgPoolOptions;

use crate::api::{finish_passkey_registration, start_passkey_registration};

mod api;
mod db;
mod passkeys;
mod types;

#[tokio::main]
async fn main() {
    let db_connection_str = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgres://postgres:postgres@localhost/supapasskeys".to_string());

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
