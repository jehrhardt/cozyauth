defmodule Supapasskeys.Servers.Server do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "servers" do
    field :subdomain, :string
    field :user, :string
    field :password, :string
    field :host, :string
    field :database_name, :string
    field :port, :integer
    field :migrated_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [
      :subdomain,
      :user,
      :password,
      :host,
      :database_name,
      :port,
      :migrated_at
    ])
    |> validate_required([
      :subdomain,
      :password,
      :host
    ])
  end
end
