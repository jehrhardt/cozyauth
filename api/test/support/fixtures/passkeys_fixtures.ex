defmodule Supapasskeys.PasskeysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Supapasskeys.Passkeys` context.
  """

  @doc """
  Generate a registration.
  """
  def registration_fixture(attrs \\ %{}) do
    {:ok, registration} =
      attrs
      |> Enum.into(%{
        state: Jason.encode!(%{"some" => "state"}),
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Supapasskeys.Passkeys.create_registration()

    registration
  end
end
