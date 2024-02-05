defmodule Supapasskeys.Passkeys.Passkey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "supapasskeys"
  schema "passkeys" do
    field :user_id, Ecto.UUID
    field :key, :string

    belongs_to :relying_party, Supapasskeys.Passkeys.RelyingParty, foreign_key: :relying_party_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(passkey, attrs) do
    passkey
    |> cast(attrs, [:user_id, :key])
    |> validate_required([:user_id, :key])
  end
end
