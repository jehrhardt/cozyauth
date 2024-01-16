defmodule Supapasskeys.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    create table(:servers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :relying_party_name, :string
      add :relying_party_origin, :string

      timestamps(type: :utc_datetime)
    end
  end
end
