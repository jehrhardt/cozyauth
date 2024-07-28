// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use axum::{extract::State, http::StatusCode, response::IntoResponse, routing::post, Json, Router};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;

use crate::model::registration::Registration;

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

async fn create(
    State(pool): State<PgPool>,
    Json(creation_params): Json<CreationParams>,
) -> impl IntoResponse {
    let user = creation_params.user;
    let user_name = user.name.as_str();
    let user_display_name = user.display_name.unwrap_or_else(|| user_name.to_string());

    match Registration::create_passkey_registration(pool, user.id, user_name, &user_display_name)
        .await
    {
        Ok((credential_creation_options, registration)) => (
            StatusCode::OK,
            Json(json!({
                "id": registration.id,
                "publicKeyCredentialCreationOptions": credential_creation_options,
                "expiresAt": registration.expires_at,
            })),
        )
            .into_response(),
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR.into_response(),
    }
}

pub(crate) fn router() -> Router<PgPool> {
    Router::new().route("/registrations", post(create))
}

#[cfg(test)]
mod tests {
    use super::*;

    use axum::{
        body::Body,
        http::{self, header, Request},
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
                    .uri("/registrations")
                    .header(header::CONTENT_TYPE, mime::APPLICATION_JSON.as_ref())
                    .body(Body::from(
                        serde_json::to_string(&json!({"user": {"id": user.id, "name": user.name, "displayName": user.display_name}})).unwrap(),
                    ))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        assert_eq!(
            response
                .headers()
                .get(header::CONTENT_TYPE)
                .unwrap()
                .to_str()
                .unwrap(),
            mime::APPLICATION_JSON
        );
        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body: Value = serde_json::from_slice(&body).unwrap();
        assert_credential_creation_options(user, body)
    }

    #[tokio::test]
    async fn create_passkey_registration_without_display_name() {
        let app = router();
        let user = User {
            id: Uuid::new_v4(),
            name: "alice".to_string(),
            display_name: None,
        };
        let response = app
            .oneshot(
                Request::builder()
                    .method(http::Method::POST)
                    .uri("/registrations")
                    .header(header::CONTENT_TYPE, mime::APPLICATION_JSON.as_ref())
                    .body(Body::from(
                        serde_json::to_string(&json!({"user": {"id": user.id, "name": user.name}}))
                            .unwrap(),
                    ))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        assert_eq!(
            response
                .headers()
                .get(header::CONTENT_TYPE)
                .unwrap()
                .to_str()
                .unwrap(),
            mime::APPLICATION_JSON
        );
        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body: Value = serde_json::from_slice(&body).unwrap();

        assert_credential_creation_options(user, body)
    }

    fn assert_credential_creation_options(user: User, json: Value) {
        let regigstration_id = json.get("id").unwrap();
        assert_eq!(
            regigstration_id
                .as_str()
                .map(|v| Uuid::parse_str(v).unwrap()),
            Some(user.id)
        );

        let creation_options = json.get("publicKeyCredentialCreationOptions").unwrap();
        let rp = creation_options.get("rp").unwrap();
        assert_eq!(rp.get("id").and_then(|v| v.as_str()), Some("localhost"));

        let user_json = creation_options.get("user").unwrap();
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

        let display_name = match user.display_name {
            Some(name) => name,
            None => user.name,
        };

        assert_eq!(
            user_json.get("displayName").and_then(|v| v.as_str()),
            Some(display_name.as_str())
        );

        assert!(creation_options
            .get("challenge")
            .map(|v| v.as_str().unwrap())
            .map(|v| general_purpose::URL_SAFE_NO_PAD.decode(v).is_ok())
            .unwrap());

        let pub_key_credentials_params = creation_options
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

        assert_eq!(
            creation_options.get("timeout").and_then(|v| v.as_u64()),
            Some(300000)
        );

        let authenticator_selection = creation_options.get("authenticatorSelection").unwrap();
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
            creation_options.get("attestation").and_then(|v| v.as_str()),
            Some("none")
        );

        let extensions = creation_options.get("extensions").unwrap();
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
