use axum::{
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    response::IntoResponse,
    routing::get,
    Router,
};
use futures::{sink::SinkExt, stream::StreamExt};
use std::net::{SocketAddr, Ipv4Addr, Ipv6Addr};

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/register", get(register_handler));

    let addr = if cfg!(debug_assertions) {
        SocketAddr::from((Ipv4Addr::LOCALHOST, 3000))
    } else {
        SocketAddr::from((Ipv6Addr::UNSPECIFIED, 3000))
    };

    println!("Listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn register_handler(ws: WebSocketUpgrade) -> impl IntoResponse {
    ws.on_upgrade(|socket| websocket(socket))
}

async fn websocket(stream: WebSocket) {
    let (mut sender, mut receiver) = stream.split();

    while let Some(Ok(message)) = receiver.next().await {
        if let Message::Text(some_message) = message {
            let _ = sender.send(Message::Text(some_message)).await;
            return;
        }
    }
}
