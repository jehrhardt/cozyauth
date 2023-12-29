pub use sea_orm_migration::prelude::*;

mod m20231211_054845_create_registration_table;
mod m20231228_220808_grant_access_to_postgres_user;

pub struct Migrator;

#[async_trait::async_trait]
impl MigratorTrait for Migrator {
    fn migrations() -> Vec<Box<dyn MigrationTrait>> {
        vec![
            Box::new(m20231211_054845_create_registration_table::Migration),
            Box::new(m20231228_220808_grant_access_to_postgres_user::Migration),
        ]
    }
}
