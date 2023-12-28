use figment::{
    providers::{Env, Format, Toml},
    Figment,
};
use serde::Deserialize;

#[derive(Debug, Clone, PartialEq, Deserialize)]
pub(crate) struct Config {
    pub(crate) database_url: String,
    pub(crate) relying_party_name: String,
    pub(crate) relying_party_origin: String,
}

pub(crate) fn load_config() -> Config {
    let figment = Figment::new()
        .merge(Toml::file("Supapasskeys.toml"))
        .merge(Env::prefixed("SUPAPASSKEYS"));
    figment.extract().unwrap()
}
