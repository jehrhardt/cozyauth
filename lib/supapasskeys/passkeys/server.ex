defmodule Supapasskeys.Passkeys.Server do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "servers" do
    field :relying_party_name, :string
    field :relying_party_origin, :string
    field :subdomain, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:relying_party_name, :relying_party_origin, :subdomain])
    |> validate_required([:relying_party_name, :relying_party_origin, :subdomain])
  end
end
