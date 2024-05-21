// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use axum::{routing::get, Json, Router};
use serde_json::json;

pub(crate) fn router() -> Router {
    Router::new().route("/health", get(|| async { Json(json!({ "status": "✅" })) }))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::{
        body::Body,
        http::{self, header, HeaderValue, Request, StatusCode},
    };
    use http_body_util::BodyExt;
    use serde_json::{json, Value};
    use tower::ServiceExt;

    #[tokio::test]
    async fn status_ok() {
        let app = router();

        let response = app
            .oneshot(
                Request::builder()
                    .method(http::Method::GET)
                    .uri("/health")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let expected_content_type =
            HeaderValue::from_str(mime::APPLICATION_JSON.to_string().as_str()).unwrap();
        assert_eq!(
            response.headers().get(header::CONTENT_TYPE),
            Some(&expected_content_type)
        );

        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body: Value = serde_json::from_slice(&body).unwrap();
        assert_eq!(body, json!({"status": "✅"}));
    }
}
