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
        id: Faker.UUID.v4(),
        name: Faker.Internet.email(),
        display_name: Faker.Person.name()
      })
      |> Supapasskeys.Passkeys.create_registration()

    registration |> Map.update!(:creation_options, fn _ -> nil end)
  end
end
