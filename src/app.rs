use axum::{
    routing::{patch, post},
    Router,
};
use migration::{Migrator, MigratorTrait};
use sea_orm::{ConnectOptions, Database, DatabaseConnection};
use std::time::Duration;

use crate::{
    api,
    config::{load_config, Config},
};

#[derive(Clone)]
pub(crate) struct Context {
    pub(crate) config: Config,
    pub(crate) db: DatabaseConnection,
}

async fn connect_to_database(config: Config) -> DatabaseConnection {
    let mut opt = ConnectOptions::new(config.database_url);
    opt.max_connections(5)
        .acquire_timeout(Duration::from_secs(3))
        .sqlx_logging(true)
        .set_schema_search_path("supapasskeys");

    Database::connect(opt)
        .await
        .expect("can't connect to database")
}

async fn migrate_database(config: Config) {
    let db = connect_to_database(config).await;
    Migrator::up(&db, None)
        .await
        .expect("can't migrate database");
}

async fn start_server(config: Config) {
    let db = connect_to_database(config.clone()).await;
    let context = Context { config, db };
    let app = Router::new()
        .route("/passkeys", post(api::registration::create))
        .route(
            "/passkeys/registrations/:registration_id",
            patch(api::registration::update),
        )
        .with_state(context);
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000")
        .await
        .unwrap();
    println!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

pub async fn start() {
    let config = load_config();
    migrate_database(config.clone()).await;
    start_server(config).await;
}
