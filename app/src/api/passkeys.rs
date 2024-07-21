// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use axum::{http::StatusCode, response::IntoResponse, routing::post, Json, Router};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use webauthn_rs::prelude::*;

#[derive(Serialize, Deserialize)]
struct User {
    id: Uuid,
    name: String,
    display_name: String,
}

async fn create(Json(user): Json<User>) -> impl IntoResponse {
    let rp_id = "localhost";
    let rp_origin = Url::parse("http://localhost")
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)
        .unwrap();

    let builder = WebauthnBuilder::new(rp_id, &rp_origin)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)
        .unwrap();

    let webauthn = builder
        .build()
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)
        .unwrap();

    match webauthn.start_passkey_registration(user.id, &user.name, &user.display_name, None) {
        Ok((ccr, _skr)) => (StatusCode::ACCEPTED, Json(ccr)).into_response(),
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR.into_response(),
    }
}

pub(crate) fn router() -> Router {
    Router::new().route("/", post(create))
}

#[cfg(test)]
mod tests {
    use super::*;

    use axum::{
        body::Body,
        http::{self, Request, StatusCode},
    };
    use http_body_util::BodyExt;
    use tower::ServiceExt;

    #[tokio::test]
    async fn create_passkey_registration() {
        let app = router();
        let user = User {
            id: Uuid::new_v4(),
            name: "alice".to_string(),
            display_name: "Alice".to_string(),
        };
        let response = app
            .oneshot(
                Request::builder()
                    .method(http::Method::POST)
                    .uri("/")
                    .header(http::header::CONTENT_TYPE, mime::APPLICATION_JSON.as_ref())
                    .body(Body::from(serde_json::to_string(&user).unwrap()))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::ACCEPTED);
        assert_eq!(
            response
                .headers()
                .get(http::header::CONTENT_TYPE)
                .unwrap()
                .to_str()
                .unwrap(),
            mime::APPLICATION_JSON
        );

        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body: CreationChallengeResponse = serde_json::from_slice(&body).unwrap();

        assert_eq!(body.public_key.rp.id, "localhost");
        assert_eq!(body.public_key.user.name, user.name);
        assert_eq!(body.public_key.user.display_name, user.display_name);
    }
}
