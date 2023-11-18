defmodule Supapasskeys.Repo.Migrations.CreatePasskeyRegistriations do
  use Ecto.Migration

  def change do
    create table(:passkey_registriations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, :uuid
      add :state, :binary

      timestamps(type: :utc_datetime)
    end
  end
end
