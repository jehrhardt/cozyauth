defmodule Supapasskeys.Passkeys.RelyingParty do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "supapasskeys"
  schema "relying_parties" do
    field :name, :string
    field :origin, :string
    field :project_id, Ecto.UUID

    has_many :registrations, Supapasskeys.Passkeys.Registration, foreign_key: :relying_party_id
    has_many :passkeys, Supapasskeys.Passkeys.Passkey, foreign_key: :relying_party_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(relying_party, attrs) do
    relying_party
    |> cast(attrs, [:name, :origin, :project_id])
    |> validate_required([:name, :origin, :project_id])
  end
end
