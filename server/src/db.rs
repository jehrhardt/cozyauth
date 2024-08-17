// Copyright 2024 Cozy Auth Contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

use sqlx::{migrate::Migrator, PgPool};

use crate::config::Settings;

static MIGRATOR: Migrator = sqlx::migrate!();

pub(crate) async fn create_pool(settings: &Settings) -> PgPool {
    let url = settings.database_url();
    PgPool::connect(url.as_str())
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
