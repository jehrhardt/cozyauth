defmodule Supapasskeys.ServerRepo.Migrations.CreatePasskeys do
  use Ecto.Migration

  def change do
    create table(:passkeys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :key, :jsonb, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
