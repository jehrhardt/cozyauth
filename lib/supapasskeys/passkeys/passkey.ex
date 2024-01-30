defmodule Supapasskeys.Passkeys.Passkey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "supapasskeys"
  schema "passkeys" do
    field :user_id, Ecto.UUID
    field :key, :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(passkey, attrs) do
    passkey
    |> cast(attrs, [:user_id, :key])
    |> validate_required([:user_id, :key])
  end
end
