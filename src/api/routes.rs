use super::registration;
use crate::app;
use axum::{
    routing::{patch, post},
    Router,
};

pub(crate) fn routes() -> Router<app::State> {
    Router::new()
        .route("/passkeys", post(registration::create))
        .route(
            "/passkeys/registrations/:registration_hash",
            patch(registration::update),
        )
}
