// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: AGPL-3.0-or-later

use sqlx::{migrate::Migrator, Pool, Postgres};

use crate::config::Settings;

static MIGRATOR: Migrator = sqlx::migrate!();

pub(crate) async fn create_pool(settings: &Settings) -> Pool<Postgres> {
    let url = settings.database_url();
    Pool::<Postgres>::connect(url.as_str())
        .await
        .expect("cannot create database pool")
}

pub(crate) async fn migrate(settings: &Settings) {
    let pool = create_pool(settings).await;
    match MIGRATOR.run(&pool).await {
        Ok(_) => println!("✅ database has been migrated"),
        Err(e) => panic!("{}", e),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn migrate_with_environment() {
        let settings = Settings::from_env();
        migrate(&settings).await;
        // Nothing paniced ✅
    }
}
