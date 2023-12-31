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
                    .col(
                        ColumnDef::new(Registration::CreatedAt)
                            .timestamp_with_time_zone()
                            .not_null()
                            .clone()
                            .default(Expr::current_timestamp()),
                    )
                    .col(
                        ColumnDef::new(Registration::UpdatedAt)
                            .timestamp_with_time_zone()
                            .not_null()
                            .clone()
                            .default(Expr::current_timestamp()),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .get_connection()
            .execute_unprepared("GRANT SELECT ON registration TO postgres;")
            .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Registration::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
pub(crate) enum Registration {
    Table,
    Id,
    UserId,
    State,
    CreatedAt,
    UpdatedAt,
}
