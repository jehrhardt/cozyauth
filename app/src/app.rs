// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use std::net::{IpAddr, Ipv4Addr, SocketAddr};

use axum::Router;
use tokio::{net::TcpListener, signal};
use tracing::info;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use crate::{api::health, config::Settings};

fn router() -> Router {
    Router::new().merge(health::router())
}

pub(crate) async fn start_server(settings: &Settings) {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "cozyauth=debug,axum::rejection=trace".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();
    let ip_address: IpAddr = if cfg!(debug_assertions) {
        Ipv4Addr::LOCALHOST.into()
    } else {
        Ipv4Addr::UNSPECIFIED.into()
    };
    let socket_address = SocketAddr::new(ip_address, settings.port.unwrap_or(3000));
    let listener = TcpListener::bind(&socket_address).await.unwrap();
    info!("Listening on {}", socket_address);
    axum::serve(listener, router().into_make_service())
        .with_graceful_shutdown(shutdown_signal())
        .await
        .unwrap()
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
