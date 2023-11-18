defmodule Supapasskeys.PasskeysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Supapasskeys.Passkeys` context.
  """

  @doc """
  Generate a passkey_registration.
  """
  def passkey_registration_fixture(attrs \\ %{}) do
    {:ok, passkey_registration} =
      attrs
      |> Enum.into(%{
        state: "some state",
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Supapasskeys.Passkeys.create_passkey_registration()

    passkey_registration
  end
end
