use axum::{routing::get, Router};

pub(crate) fn router() -> Router {
    Router::new().route("/health", get(|| async { "OK" }))
}
