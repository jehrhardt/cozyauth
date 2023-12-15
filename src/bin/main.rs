#[tokio::main]
async fn main() {
    let context = supapasskeys::app::create_context().await;
    let app = supapasskeys::api::routes::mount().with_state(context);
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000")
        .await
        .unwrap();
    println!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}
