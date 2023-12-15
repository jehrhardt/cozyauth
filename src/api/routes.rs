use super::registration;
use crate::app;
use axum::{
    routing::{patch, post},
    Router,
};

pub fn mount() -> Router<app::Context> {
    Router::new()
        .route("/passkeys", post(registration::create))
        .route(
            "/passkeys/registrations/:registration_id",
            patch(registration::update),
        )
}
