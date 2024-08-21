// Copyright 2024 Cozy Auth Contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{patch, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use uuid::Uuid;
use webauthn_rs::prelude::*;

use crate::{app::AppContext, model::registration::Registration};

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
    State(ctx): State<AppContext>,
    Json(creation_params): Json<CreationParams>,
) -> impl IntoResponse {
    let user = creation_params.user;
    let user_name = user.name.as_str();
    let user_display_name = user.display_name.unwrap_or_else(|| user_name.to_string());
    match Registration::create_passkey_registration(
        &ctx.pool,
        &ctx.settings.relying_party_domain,
        user.id,
        user_name,
        &user_display_name,
    )
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
    State(ctx): State<AppContext>,
    Path(id): Path<Uuid>,
    Json(credential): Json<RegisterPublicKeyCredential>,
) -> StatusCode {
    let pool = &ctx.pool;
    match Registration::find_unconfirmed_by_id(pool, id).await {
        Ok(registration) => match registration
            .confirm(pool, &ctx.settings.relying_party_domain, &credential)
            .await
        {
            Ok(_) => StatusCode::NO_CONTENT,
            Err(_) => StatusCode::BAD_REQUEST,
        },
        Err(_) => StatusCode::NOT_FOUND,
    }
}

pub(crate) fn router() -> Router<AppContext> {
    Router::new()
        .route("/registrations", post(create))
        .route("/registrations/:id/confirmation", patch(confirm))
}
