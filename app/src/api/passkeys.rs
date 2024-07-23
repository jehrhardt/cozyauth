// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use axum::{
    http::{header, StatusCode},
    response::IntoResponse,
    routing::post,
    Json, Router,
};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use webauthn_rs::prelude::*;

#[derive(Serialize, Deserialize)]
struct CreationParams {
    user: User,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct User {
    id: Uuid,
    name: String,
    display_name: Option<String>,
}

static DUMMY_REG_ID: &str = "foo";

async fn create(Json(creation_params): Json<CreationParams>) -> impl IntoResponse {
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

    let user = creation_params.user;
    let user_name = user.name.as_str();
    let user_display_name = user.display_name.unwrap_or_else(|| user_name.to_string());

    match webauthn.start_passkey_registration(user.id, user_name, &user_display_name, None) {
        Ok((ccr, _skr)) => (
            StatusCode::ACCEPTED,
            [(
                header::LOCATION,
                format!("/passkeys/registrations/{}", DUMMY_REG_ID),
            )],
            Json(ccr.public_key),
        )
            .into_response(),
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
        http::{self, Request},
    };
    use base64::{engine::general_purpose, Engine};
    use http_body_util::BodyExt;
    use serde_json::{json, Value};
    use tower::ServiceExt;

    #[tokio::test]
    async fn create_passkey_registration() {
        let app = router();
        let user = User {
            id: Uuid::new_v4(),
            name: "alice".to_string(),
            display_name: Some("Alice".to_string()),
        };
        let response = app
            .oneshot(
                Request::builder()
                    .method(http::Method::POST)
                    .uri("/")
                    .header(header::CONTENT_TYPE, mime::APPLICATION_JSON.as_ref())
                    .body(Body::from(
                        serde_json::to_string(&json!({"user": {"id": user.id, "name": user.name, "displayName": user.display_name}})).unwrap(),
                    ))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::ACCEPTED);
        assert_eq!(
            response
                .headers()
                .get(header::CONTENT_TYPE)
                .unwrap()
                .to_str()
                .unwrap(),
            mime::APPLICATION_JSON
        );
        assert_eq!(
            response
                .headers()
                .get(header::LOCATION)
                .unwrap()
                .to_str()
                .unwrap(),
            "/passkeys/registrations/foo"
        );

        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body: Value = serde_json::from_slice(&body).unwrap();

        assert_credential_creation_options(user, body)
    }

    fn assert_credential_creation_options(user: User, json: Value) {
        let rp = json.get("rp").unwrap();
        assert_eq!(rp.get("id").and_then(|v| v.as_str()), Some("localhost"));

        let user_json = json.get("user").unwrap();
        let user_id = user.id.as_bytes().to_vec();
        assert_eq!(
            user_json
                .get("id")
                .map(|v| v.as_str().unwrap())
                .map(|v| general_purpose::URL_SAFE_NO_PAD.decode(v).unwrap()),
            Some(user_id)
        );

        assert_eq!(
            user_json.get("name").and_then(|v| v.as_str()),
            Some(user.name.as_str())
        );

        let display_name = user.display_name.unwrap();
        assert_eq!(
            user_json.get("displayName").and_then(|v| v.as_str()),
            Some(display_name.as_str())
        );

        assert!(json
            .get("challenge")
            .map(|v| v.as_str().unwrap())
            .map(|v| general_purpose::URL_SAFE_NO_PAD.decode(v).is_ok())
            .unwrap());

        let pub_key_credentials_params = json
            .get("pubKeyCredParams")
            .map(|v| v.as_array().unwrap())
            .unwrap();
        assert_eq!(pub_key_credentials_params.len(), 2);
        assert_eq!(
            pub_key_credentials_params
                .first()
                .and_then(|v| v.get("alg").unwrap().as_i64()),
            Some(-7)
        );
        assert_eq!(
            pub_key_credentials_params
                .get(1)
                .and_then(|v| v.get("alg").unwrap().as_i64()),
            Some(-257)
        );

        assert_eq!(json.get("timeout").and_then(|v| v.as_u64()), Some(300000));

        let authenticator_selection = json.get("authenticatorSelection").unwrap();
        assert_eq!(
            authenticator_selection
                .get("residentKey")
                .and_then(|v| v.as_str()),
            Some("discouraged")
        );
        assert_eq!(
            authenticator_selection
                .get("requireResidentKey")
                .and_then(|v| v.as_bool()),
            Some(false)
        );
        assert_eq!(
            authenticator_selection
                .get("userVerification")
                .and_then(|v| v.as_str()),
            Some("required")
        );

        assert_eq!(
            json.get("attestation").and_then(|v| v.as_str()),
            Some("none")
        );

        let extensions = json.get("extensions").unwrap();
        assert_eq!(
            extensions
                .get("credentialProtectionPolicy")
                .and_then(|v| v.as_str()),
            Some("userVerificationRequired")
        );
        assert_eq!(
            extensions
                .get("enforceCredentialProtectionPolicy")
                .and_then(|v| v.as_bool()),
            Some(false)
        );
        assert_eq!(extensions.get("uvm").and_then(|v| v.as_bool()), Some(true));
        assert_eq!(
            extensions.get("credProps").and_then(|v| v.as_bool()),
            Some(true)
        );
    }
}
