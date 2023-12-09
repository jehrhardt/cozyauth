use serde::Deserialize;
use uuid::Uuid;

pub(crate) struct RelyingParty {
    pub(crate) name: String,
    pub(crate) origin: String,
}

#[derive(Deserialize, Clone)]
pub(crate) struct User {
    pub(crate) id: Uuid,
    pub(crate) name: String,
    pub(crate) display_name: String,
}
