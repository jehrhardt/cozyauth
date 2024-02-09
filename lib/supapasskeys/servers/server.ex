defmodule Supapasskeys.Servers.Server do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "servers" do
    field :subdomain, :string
    field :database_url, :string
    field :migrated_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:subdomain, :database_url, :migrated_at])
    |> validate_required([:subdomain, :database_url])
  end
end
