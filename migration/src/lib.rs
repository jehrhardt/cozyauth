pub use sea_orm_migration::prelude::*;

mod m20231211_054845_create_registration_table;
mod m20231212_051917_create_server_table;
mod m20231212_052949_add_server_id_fk_to_registration_table;

pub struct Migrator;

#[async_trait::async_trait]
impl MigratorTrait for Migrator {
    fn migrations() -> Vec<Box<dyn MigrationTrait>> {
        vec![
            Box::new(m20231211_054845_create_registration_table::Migration),
            Box::new(m20231212_051917_create_server_table::Migration),
            Box::new(m20231212_052949_add_server_id_fk_to_registration_table::Migration),
        ]
    }
}
