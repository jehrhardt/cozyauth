use axum::{
    extract::{Path, State},
    Json,
};
use serde_json::{json, Value};
use uuid::Uuid;
use webauthn_rs::prelude::Url;
use webauthn_rs_proto::RegisterPublicKeyCredential;

use crate::{
    app,
    models::{
        entities::registration::Model,
        registration::{Registration, RelyingParty, UserParams},
    },
};

pub async fn create(
    State(context): State<app::Context>,
    Json(params): Json<UserParams>,
) -> Json<Registration> {
    let relying_party = RelyingParty {
        name: context.config.relying_party_name.clone(),
        origin: Url::parse(&context.config.relying_party_origin).unwrap(),
    };
    let registration = Model::new(&context.db, relying_party, params)
        .await
        .unwrap();
    Json(registration)
}

pub async fn update(
    State(context): State<app::Context>,
    Path(registration_id): Path<Uuid>,
    Json(reg): Json<RegisterPublicKeyCredential>,
) -> Json<Value> {
    let relying_party = RelyingParty {
        name: context.config.relying_party_name.clone(),
        origin: Url::parse(&context.config.relying_party_origin).unwrap(),
    };
    let registration = Model::find_by_id(&context.db, registration_id)
        .await
        .unwrap();
    let passkey = registration.confirm(relying_party, &reg).unwrap();
    let message = format!("Passkey {} registered ✅", passkey.cred_id());
    Json(json!({ "ok": message }))
}
