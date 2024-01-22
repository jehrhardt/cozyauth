defmodule Supapasskeys.Passkeys.Passkey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "passkeys" do
    field :key, :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(passkey, attrs) do
    passkey
    |> cast(attrs, [:key])
    |> validate_required([:key])
  end
end
