defmodule Supapasskeys.Repo.Migrations.CreateRegistrations do
  use Ecto.Migration

  def change do
    create table(:registrations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, :uuid
      add :state, :jsonb, null: true
      add :confirmed_at, :utc_datetime, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
