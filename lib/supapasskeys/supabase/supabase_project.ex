defmodule Supapasskeys.Supabase.SupabaseProject do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "supabase_projects" do
    field :project_id, :string
    field :database_url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(supabase_project, attrs) do
    supabase_project
    |> cast(attrs, [:project_id, :database_url])
    |> validate_required([:project_id, :database_url])
  end
end
