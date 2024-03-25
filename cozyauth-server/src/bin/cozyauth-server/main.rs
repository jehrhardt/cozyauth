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
