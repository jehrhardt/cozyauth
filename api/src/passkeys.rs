// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use axum::{routing::post, Json, Router};
use uuid::Uuid;
use webauthn_rs::{
    prelude::{CreationChallengeResponse, Url},
    WebauthnBuilder,
};

async fn create() -> Json<CreationChallengeResponse> {
    let rp_id = "example.com";
    let rp_origin = Url::parse("https://idm.example.com").unwrap();
    let webauthn = WebauthnBuilder::new(rp_id, &rp_origin)
        .unwrap()
        .build()
        .unwrap();
    let (x, _) = webauthn
        .start_passkey_registration(Uuid::new_v4(), "foo", "Foo", None)
        .unwrap();
    Json(x)
}

pub(crate) fn router() -> Router {
    Router::new().route("/", post(create))
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
    async fn simple_request() {
        let app = router();

        let response = app
            .oneshot(
                Request::builder()
                    .method(http::Method::POST)
                    .uri("/")
                    .header(header::CONTENT_TYPE, mime::APPLICATION_JSON.as_ref())
                    .body(Body::from(
                        serde_json::to_vec(&json!({ "id": "", "name": "Foo" })).unwrap(),
                    ))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::ACCEPTED);

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
