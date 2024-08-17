// © Copyright 2024 Cozy Bytes GmbH

use cozyauth_cloud::app;

#[tokio::main]
async fn main() {
    app::run().await;
}
