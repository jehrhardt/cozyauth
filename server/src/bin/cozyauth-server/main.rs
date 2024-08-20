#[tokio::main]
async fn main() {
    cozyauth_server::cli::run().await;
}
