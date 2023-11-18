use rocket::{launch, post, routes, serde::json::Json};
use rocket_db_pools::{Connection, Database};
use sqlx::PgPool;
use uuid::Uuid;
use webauthn_rs_proto::{PublicKeyCredentialCreationOptions, RegisterPublicKeyCredential};

use crate::types::User;

mod db;
mod passkeys;
mod types;

#[derive(Database)]
#[database("supapasskeys")]
pub(crate) struct Db(PgPool);

#[post("/", data = "<user_json>")]
async fn start_passkey_registration(
    mut db: Connection<Db>,
    user_json: Json<User<'_>>,
) -> Json<PublicKeyCredentialCreationOptions> {
    let relying_party = db::get_relying_party(&mut **db).unwrap();
    let user = user_json.into_inner();
    let (ccr, skr) = passkeys::start_registration(relying_party, user);
    db::new_passkey_registration(&mut **db, user.id, skr)
        .await
        .unwrap();
    Json(ccr.public_key)
}

#[post("/<user_id>", data = "<reg>")]
async fn finish_passkey_registration(
    mut db: Connection<Db>,
    user_id: Uuid,
    reg: Json<RegisterPublicKeyCredential>,
) -> String {
    let relying_party = db::get_relying_party(&mut **db).unwrap();
    let state = db::get_passkey_registration(&mut **db, user_id)
        .await
        .unwrap();
    let passkey = passkeys::finish_registration(relying_party, reg.into_inner(), state);
    format!("Passkey {} registered ✅", passkey.cred_id())
}

#[launch]
fn rocket() -> _ {
    rocket::build().attach(Db::init()).mount(
        "/passkeys",
        routes![start_passkey_registration, finish_passkey_registration],
    )
}
