use axum::{
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    response::IntoResponse,
    routing::get,
    Router,
};
use futures::{sink::SinkExt, stream::StreamExt};
use json_rpc::{handle_json_rpc_request, JsonRpcMethod};
use std::{
    net::{Ipv4Addr, Ipv6Addr, SocketAddr},
    sync::{Arc, Mutex},
};
use webauthn_rs::prelude::PasskeyRegistration;

mod json_rpc;
mod passkeys;

#[tokio::main]
async fn main() {
    let app = Router::new().route("/register", get(register_handler));

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

    let relying_party = passkeys::RelyingParty {
        name: "Example".to_string(),
        origin: "http://localhost:4000".to_string(),
    };

    let passkey_registration: Arc<Mutex<Option<PasskeyRegistration>>> = Arc::new(Mutex::new(None));
    let reg_state = passkey_registration.clone();
    while let Some(Ok(message)) = receiver.next().await {
        if let Message::Text(request) = message {
            let response = handle_json_rpc_request(&request, JsonRpcMethod::START, |user| {
                let (ccr, skr) = passkeys::start_registration(relying_party, user);
                reg_state.lock().unwrap().replace(skr);
                ccr
            })
            .await;
            let _ = sender.send(Message::Text(response)).await;
            return;
        }
    }

    while let Some(Ok(message)) = receiver.next().await {
        if let Message::Text(request) = message {
            let response = handle_json_rpc_request(&request, JsonRpcMethod::FINISH, |reg| {
                let state = passkey_registration.lock().unwrap().clone().unwrap();
                passkeys::finish_registration(relying_party, reg, state)
            })
            .await;
            let _ = sender.send(Message::Text(response)).await;
            return;
        }
    }
}
