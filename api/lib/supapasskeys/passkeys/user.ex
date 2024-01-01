defmodule Supapasskeys.Passkeys.User do
  alias Supapasskeys.WebAuthn
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :name, :string
    field :display_name, :string
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :name, :display_name])
    |> validate_required([:id, :name, :display_name])
  end

  def to_webauthn_user(changeset) do
    if changeset.valid? do
      {:ok, struct(WebAuthn.User, changeset.changes)}
    else
      {:error, changeset}
    end
  end
end
