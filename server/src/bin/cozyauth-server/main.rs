// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use std::{
    net::{IpAddr, Ipv4Addr, SocketAddr},
    time::Duration,
};

use axum::{
    extract::FromRef,
    routing::{get, post},
    Json, Router,
};
use serde_json::json;
use sqlx::postgres::PgPoolOptions;
use tokio::{net::TcpListener, signal};
use tracing::info;
use tracing_subscriber::{self, layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "cozyauth_server=debug,axum::rejection=trace".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();
    let db_connection_str =
        std::env::var("DATABASE_URL").expect("environment variable DATABASE_URL required");
    let app_context = Context::new();
    let app = Router::new()
        .route("/health", get(|| async { Json(json!({ "status": "✅" })) }))
        .route("/passkeys", post(cozyauth_passkeys::create_passkey))
        .with_state(app_context);
    let ip_address: IpAddr = if cfg!(debug_assertions) {
        Ipv4Addr::LOCALHOST.into()
    } else {
        Ipv4Addr::UNSPECIFIED.into()
    };
    let socket_address = SocketAddr::new(ip_address, server_port());
    let listener = TcpListener::bind(&socket_address).await.unwrap();
    info!("Listening on {}", socket_address);
    axum::serve(listener, app.into_make_service())
        .with_graceful_shutdown(shutdown_signal())
        .await
        .unwrap()
}

fn server_port() -> u16 {
    std::env::var("PORT")
        .ok()
        .and_then(|port| port.parse().ok())
        .unwrap_or(3000)
}

async fn shutdown_signal() {
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }
}

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
