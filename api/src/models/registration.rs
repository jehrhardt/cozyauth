use super::entities::{
    prelude::Registration,
    registration::{ActiveModel, Model},
};
use sea_orm::{
    ActiveModelTrait, ActiveValue, DatabaseConnection, DbErr, EntityTrait, TransactionTrait,
};
use serde::Deserialize;
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

impl Model {
    pub async fn new(
        db: &DatabaseConnection,
        relying_party: RelyingParty,
        params: UserParams,
    ) -> Result<(CreationChallengeResponse, Model), DbErr> {
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
                    user_id: ActiveValue::set(params.id),
                    ..Default::default()
                }
                .insert(&txn)
                .await?;
                txn.commit().await?;
                Ok((ccr, registration))
            }
            Err(e) => panic!("Error: {}", e),
        }
    }

    pub async fn find_by_id(db: &DatabaseConnection, id: Uuid) -> Result<Model, DbErr> {
        Registration::find_by_id(id)
            .one(db)
            .await
            .map(|opt| opt.unwrap())
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
