// © Copyright 2024 Cozy Bytes GmbH

use cozyauth_cloud::cli;

#[tokio::main]
async fn main() {
    cli::run().await;
}
