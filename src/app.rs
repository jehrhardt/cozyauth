use std::time::Duration;

use axum::Router;
use figment::{
    providers::{Env, Format, Toml},
    Figment,
};
use serde::Deserialize;
use sqlx::{postgres::PgPoolOptions, Pool, Postgres};

use crate::api::routes::routes;

#[derive(Debug, Clone, PartialEq, Deserialize)]
struct Config {
    database_url: String,
}

#[derive(Clone)]
pub(crate) struct State {
    pub(crate) config: Config,
    pub(crate) pool: Pool<Postgres>,
}

fn load_config() -> Config {
    let figment = Figment::new()
        .merge(Toml::file("Supapasskeys.toml"))
        .merge(Env::prefixed("SUPAPASSKEYS"));
    figment.extract().unwrap()
}

async fn connect_to_database(config: &Config) -> Pool<Postgres> {
    PgPoolOptions::new()
        .max_connections(5)
        .acquire_timeout(Duration::from_secs(3))
        .connect(&config.database_url)
        .await
        .expect("can't connect to database")
}

pub async fn start() -> Router<State> {
    let config = load_config();
    let pool = connect_to_database(&config).await;
    let state = State { config, pool };
    routes().with_state(state)
}
