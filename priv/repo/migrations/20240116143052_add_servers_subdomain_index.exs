defmodule Supapasskeys.Repo.Migrations.AddServersSubdomainIndex do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create unique_index(:servers, [:subdomain], concurrently: true)
  end
end
