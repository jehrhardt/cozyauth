defmodule Supapasskeys.Passkeys.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "registrations" do
    field :state, :binary
    field :user_id, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:user_id, :state])
    |> validate_required([:user_id, :state])
  end
end
