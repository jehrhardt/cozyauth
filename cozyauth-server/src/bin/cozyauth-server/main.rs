// © Copyright 2024 Jan Ehrhardt
// SPDX-License-Identifier: AGPL-3.0-or-later OR Apache-2.0

use cozyauth::app;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let app = app::app();
    let listener = TcpListener::bind("127.0.0.1:3000").await.unwrap();
    axum::serve(listener, app.into_make_service())
        .await
        .unwrap()
}
