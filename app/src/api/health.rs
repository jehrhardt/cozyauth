// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use axum::{routing::get, Json, Router};
use serde_json::json;
use sqlx::PgPool;

pub(crate) fn router() -> Router<PgPool> {
    Router::new().route("/health", get(|| async { Json(json!({ "status": "✅" })) }))
}
