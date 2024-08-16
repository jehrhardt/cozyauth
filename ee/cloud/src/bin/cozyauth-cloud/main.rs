use cozyauth_cloud::app;

#[tokio::main]
async fn main() {
    app::run().await;
}
