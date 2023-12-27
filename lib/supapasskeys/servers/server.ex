defmodule Supapasskeys.Servers.Server do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "servers" do
    field :port, :integer
    field :user, :string
    field :host, :string
    field :password, :string
    field :database_name, :string
    field :relying_party_url, :string
    field :relying_party_name, :string
    field :migrated_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [
      :host,
      :database_name,
      :port,
      :user,
      :password,
      :relying_party_url,
      :relying_party_name,
      :migrated_at
    ])
    |> validate_required([
      :host,
      :database_name,
      :port,
      :user,
      :password,
      :relying_party_url,
      :relying_party_name
    ])
  end
end
