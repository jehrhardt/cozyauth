use sea_orm_migration::prelude::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Registration::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Registration::Id)
                            .uuid()
                            .not_null()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Registration::UserId).uuid().not_null())
                    .col(ColumnDef::new(Registration::State).json_binary().not_null())
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Registration::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Registration {
    Table,
    Id,
    UserId,
    State,
}
