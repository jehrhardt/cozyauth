// © Copyright 2024 Jan Ehrhardt
// SPDX-License-Identifier: AGPL-3.0-or-later OR Apache-2.0

use std::net::{IpAddr, Ipv4Addr, SocketAddr};

use cozyauth_server::app;
use tokio::net::TcpListener;
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
    let app = app::app();
    let ip_address: IpAddr = if cfg!(debug_assertions) {
        Ipv4Addr::LOCALHOST.into()
    } else {
        Ipv4Addr::UNSPECIFIED.into()
    };
    let socket_address = SocketAddr::new(ip_address, 3000);
    let listener = TcpListener::bind(&socket_address).await.unwrap();
    info!("Listening on {}", socket_address);
    axum::serve(listener, app.into_make_service())
        .await
        .unwrap()
}
