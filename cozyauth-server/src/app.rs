// © Copyright 2024 Jan Ehrhardt
// SPDX-License-Identifier: AGPL-3.0-or-later OR Apache-2.0

use crate::api::health;
use axum::Router;

pub fn app() -> Router {
    Router::new().merge(health::router())
}
