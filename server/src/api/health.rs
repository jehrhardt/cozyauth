// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: GPL-3.0-or-later

use axum::{routing::get, Json, Router};
use serde_json::json;

pub(crate) fn router() -> Router {
    Router::new().route(
        "/health",
        get(|| async { Json(json!( { "status": "✅" })) }),
    )
}

#[cfg(test)]
mod test {
    use super::*;
    use axum::{
        body::Body,
        http::{header::CONTENT_TYPE, Request, StatusCode},
    };
    use http_body_util::BodyExt;
    use serde_json::Value;
    use tower::ServiceExt;

    #[tokio::test]
    async fn health() {
        let app = router();

        let response = app
            .oneshot(
                Request::builder()
                    .uri("/health")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        assert_eq!(response.headers()[CONTENT_TYPE], "application/json");

        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body: Value = serde_json::from_slice(&body).unwrap();
        assert_eq!(body, json!({ "status": "✅" }));
    }
}
