use figment::{
    providers::{Env, Format, Toml},
    Figment,
};
use sea_orm::{ConnectOptions, Database, DatabaseConnection};
use serde::Deserialize;
use std::time::Duration;

#[derive(Debug, Clone, PartialEq, Deserialize)]
pub struct Config {
    database_url: String,
    pub relying_party_name: String,
    pub relying_party_origin: String,
}

#[derive(Clone)]
pub struct Context {
    pub config: Config,
    pub db: DatabaseConnection,
}

fn load_config() -> Config {
    let figment = Figment::new()
        .merge(Toml::file("Supapasskeys.toml"))
        .merge(Env::prefixed("SUPAPASSKEYS"));
    figment.extract().unwrap()
}

async fn connect_to_database(config: &Config) -> DatabaseConnection {
    let mut opt = ConnectOptions::new(config.database_url.as_str());
    opt.max_connections(5)
        .acquire_timeout(Duration::from_secs(3))
        .sqlx_logging(true);

    Database::connect(opt)
        .await
        .expect("can't connect to database")
}

pub async fn create_context() -> Context {
    let config = load_config();
    let db = connect_to_database(&config).await;
    Context { config, db }
}
