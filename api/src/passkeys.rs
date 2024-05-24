// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use axum::{http::StatusCode, response::IntoResponse, routing::post, Json, Router};
use serde::Deserialize;
use uuid::Uuid;
use webauthn_rs::{prelude::Url, WebauthnBuilder};

#[derive(Deserialize)]
struct UserParams {
    id: Uuid,
    name: String,
    display_name: Option<String>,
}

async fn create(Json(user): Json<UserParams>) -> impl IntoResponse {
    let rp_id = "example.com";
    let rp_origin = Url::parse("https://idm.example.com").unwrap();
    let webauthn = WebauthnBuilder::new(rp_id, &rp_origin)
        .unwrap()
        .build()
        .unwrap();
    let (x, _) = webauthn
        .start_passkey_registration(
            user.id,
            &user.name,
            &user.display_name.unwrap_or(user.name.to_string()),
            None,
        )
        .unwrap();
    (StatusCode::ACCEPTED, Json(x))
}

pub(crate) fn router() -> Router {
    Router::new().route("/", post(create))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::{
        body::Body,
        http::{self, header, HeaderValue, Request},
    };
    use http_body_util::BodyExt;
    use serde_json::json;
    use tower::ServiceExt;
    use webauthn_rs::prelude::{Base64UrlSafeData, CreationChallengeResponse};

    #[tokio::test]
    async fn simple_request() {
        let app = router();

        let user_id = Uuid::new_v4();
        let response = app
            .oneshot(
                Request::builder()
                    .method(http::Method::POST)
                    .uri("/")
                    .header(header::CONTENT_TYPE, mime::APPLICATION_JSON.as_ref())
                    .body(Body::from(
                        serde_json::to_vec(&json!({ "id": user_id, "name": "Foo" })).unwrap(),
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
        let options: CreationChallengeResponse = serde_json::from_slice(&body).unwrap();
        let user_id_encoded: Base64UrlSafeData = user_id.as_bytes().into();
        assert_eq!(options.public_key.user.id, user_id_encoded);
        assert_eq!(options.public_key.user.name, "Foo");
        assert_eq!(options.public_key.user.display_name, "Foo");
    }
}
