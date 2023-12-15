defmodule Supapasskeys.Repo.Migrations.CreateSupabaseProjects do
  use Ecto.Migration

  def change do
    create table(:supabase_projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :project_id, :string
      add :database_url, :string

      timestamps(type: :utc_datetime)
    end
  end
end
