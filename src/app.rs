use crate::api::health;
use axum::Router;

pub fn app() -> Router {
    Router::new().merge(health::router())
}
