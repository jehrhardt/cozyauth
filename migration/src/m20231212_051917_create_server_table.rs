use sea_orm_migration::prelude::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Server::Table)
                    .if_not_exists()
                    .col(ColumnDef::new(Server::Id).uuid().not_null().primary_key())
                    .col(ColumnDef::new(Server::RelyingPartyName).string().not_null())
                    .col(
                        ColumnDef::new(Server::RelyingPartyOrigin)
                            .string()
                            .not_null(),
                    )
                    .col(
                        ColumnDef::new(Server::CreatedAt)
                            .timestamp_with_time_zone()
                            .not_null()
                            .clone()
                            .default(Expr::current_timestamp()),
                    )
                    .col(
                        ColumnDef::new(Server::UpdatedAt)
                            .timestamp_with_time_zone()
                            .not_null()
                            .clone()
                            .default(Expr::current_timestamp()),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Server::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
pub(crate) enum Server {
    Table,
    Id,
    RelyingPartyName,
    RelyingPartyOrigin,
    CreatedAt,
    UpdatedAt,
}
