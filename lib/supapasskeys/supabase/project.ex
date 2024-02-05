defmodule Supapasskeys.Supabase.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :name, :string
    field :reference_id, :string
    field :database_url, :string
    field :migrated_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :reference_id, :database_url, :migrated_at])
    |> validate_required([:name, :reference_id, :database_url])
  end
end
