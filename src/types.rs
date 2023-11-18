use serde::Deserialize;
use uuid::Uuid;

pub(crate) struct RelyingParty {
    pub(crate) name: String,
    pub(crate) origin: String,
}

#[derive(Deserialize, Clone, Copy)]
#[serde(crate = "rocket::serde")]
pub(crate) struct User<'r> {
    pub(crate) id: Uuid,
    pub(crate) name: &'r str,
    pub(crate) display_name: &'r str,
}
