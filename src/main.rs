use axum::{
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    response::IntoResponse,
    routing::get,
    Router,
};
use futures::{sink::SinkExt, stream::StreamExt};
use std::net::{SocketAddr, Ipv4Addr, Ipv6Addr};

mod passkeys;

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

    let (ccr, _skr) = passkeys::start_registration(
        passkeys::RelyingParty {
            name: "Example".to_string(),
            origin: "http://localhost:4000".to_string(),
        },
        passkeys::User {
            id: uuid::Uuid::new_v4(),
            name: "example".to_string(),
            display_name: "Example".to_string(),
        },
    );

    while let Some(Ok(message)) = receiver.next().await {
        if let Message::Text(_some_message) = message {
            let ccr_json = serde_json::to_string(&ccr.public_key).unwrap();
            let _ = sender.send(Message::Text(ccr_json)).await;
            return;
        }
    }
}
