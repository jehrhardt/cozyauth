// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{patch, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;
use webauthn_rs::prelude::*;

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

    match Registration::create_passkey_registration(&pool, user.id, user_name, &user_display_name)
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

async fn confirm(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
    Json(credential): Json<RegisterPublicKeyCredential>,
) -> StatusCode {
    match Registration::find_unconfirmed_by_id(&pool, id).await {
        Ok(registration) => match registration.confirm(&pool, &credential).await {
            Ok(_) => StatusCode::NO_CONTENT,
            Err(_) => StatusCode::BAD_REQUEST,
        },
        Err(_) => StatusCode::NOT_FOUND,
    }
}

pub(crate) fn router() -> Router<PgPool> {
    Router::new()
        .route("/registrations", post(create))
        .route("/registrations/:id/confirmation", patch(confirm))
}
