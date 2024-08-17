use cozyauth_cli::cli;

#[tokio::main]
async fn main() {
    cli::run().await;
}
