use sea_orm_migration::prelude::*;

use crate::{
    m20231211_054845_create_registration_table::Registration,
    m20231212_051917_create_server_table::Server,
};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Registration::Table)
                    .add_column(ColumnDef::new(Registration::ServerId).uuid().not_null())
                    .add_foreign_key(
                        TableForeignKey::new()
                            .name("fk_registration_server_id")
                            .from_tbl(Registration::Table)
                            .from_col(Registration::ServerId)
                            .to_tbl(Server::Table)
                            .to_col(Server::Id)
                            .on_delete(ForeignKeyAction::Cascade)
                            .on_update(ForeignKeyAction::Cascade),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let _ = manager
            .drop_foreign_key(
                ForeignKey::drop()
                    .name("fk_registration_server_id")
                    .to_owned(),
            )
            .await;
        manager
            .alter_table(
                Table::alter()
                    .table(Registration::Table)
                    .drop_column(Registration::ServerId)
                    .to_owned(),
            )
            .await
    }
}
