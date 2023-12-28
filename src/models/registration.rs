use super::entities::registration::{ActiveModel, Entity, Model};
use sea_orm::{
    ActiveModelTrait, ActiveValue, DatabaseConnection, DbErr, EntityTrait, TransactionTrait,
};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use webauthn_rs::{
    prelude::{Passkey, PasskeyRegistration, Url},
    WebauthnBuilder,
};
use webauthn_rs_proto::{CreationChallengeResponse, RegisterPublicKeyCredential};

#[derive(Debug)]
pub struct RelyingParty {
    pub name: String,
    pub origin: Url,
}

#[derive(Debug, Deserialize)]
pub struct UserParams {
    pub id: Uuid,
    pub name: String,
    pub display_name: String,
}

#[derive(Debug, Serialize)]
pub struct Registration {
    pub id: Uuid,
    pub creation_challenge: CreationChallengeResponse,
}

impl Model {
    pub async fn new(
        db: &DatabaseConnection,
        relying_party: RelyingParty,
        params: UserParams,
    ) -> Result<Registration, DbErr> {
        let rp_id = relying_party.origin.domain().unwrap();
        let webauthn = WebauthnBuilder::new(rp_id, &relying_party.origin)
            .map(|builder| builder.rp_name(&relying_party.name))
            .unwrap()
            .build()
            .unwrap();
        match webauthn.start_passkey_registration(
            params.id,
            &params.name,
            &params.display_name,
            None,
        ) {
            Ok((ccr, skr)) => {
                let skr_json = serde_json::to_value(skr).unwrap();
                let txn = db.begin().await?;
                let registration = ActiveModel {
                    state: ActiveValue::set(skr_json),
                    ..Default::default()
                }
                .insert(&txn)
                .await?;
                txn.commit().await?;
                Ok(Registration {
                    id: registration.id,
                    creation_challenge: ccr,
                })
            }
            Err(e) => panic!("Error: {}", e),
        }
    }

    pub async fn find_by_id(db: &DatabaseConnection, id: Uuid) -> Result<Model, DbErr> {
        Entity::find_by_id(id).one(db).await.map(|opt| opt.unwrap())
    }

    pub fn confirm(
        self,
        relying_party: RelyingParty,
        reg: &RegisterPublicKeyCredential,
    ) -> Result<Passkey, DbErr> {
        let state = serde_json::from_value::<PasskeyRegistration>(self.state).unwrap();
        let rp_id = relying_party.origin.domain().unwrap();
        let webauthn = WebauthnBuilder::new(rp_id, &relying_party.origin)
            .map(|builder| builder.rp_name(&relying_party.name))
            .unwrap()
            .build()
            .unwrap();
        let passkey = webauthn.finish_passkey_registration(reg, &state).unwrap();
        Ok(passkey)
    }
}
