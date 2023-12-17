defmodule Supapasskeys.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    create table(:servers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :host, :string
      add :database_name, :string
      add :port, :integer
      add :user, :string
      add :password, :string
      add :relying_party_url, :string
      add :relying_party_name, :string
      add :migrated_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
