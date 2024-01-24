defmodule Supapasskeys.Servers.Server do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "servers" do
    field :relying_party_name, :string
    field :relying_party_origin, :string
    field :subdomain, :string
    field :user, :string
    field :password, :string
    field :host, :string
    field :database_name, :string
    field :port, :integer
    field :schema_name, :string
    field :migrated_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [
      :relying_party_name,
      :relying_party_origin,
      :subdomain,
      :user,
      :password,
      :host,
      :database_name,
      :port,
      :schema_name,
      :migrated_at
    ])
    |> validate_required([
      :relying_party_name,
      :relying_party_origin,
      :subdomain,
      :password,
      :host
    ])
  end
end
