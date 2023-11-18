defmodule Supapasskeys.Passkeys.PasskeyRegistration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "passkey_registriations" do
    field :state, :binary
    field :user_id, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(passkey_registration, attrs) do
    passkey_registration
    |> cast(attrs, [:user_id, :state])
    |> validate_required([:user_id, :state])
  end
end
