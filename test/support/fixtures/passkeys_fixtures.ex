defmodule Supapasskeys.PasskeysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Supapasskeys.Passkeys` context.
  """

  @doc """
  Generate a registration.
  """
  def registration_fixture(server, relying_party, attrs \\ %{}) do
    user =
      attrs
      |> Enum.into(%{
        id: Faker.UUID.v4(),
        name: Faker.Internet.email(),
        display_name: Faker.Person.name()
      })

    {:ok, registration} = Supapasskeys.Passkeys.create_registration(server, relying_party, user)
    registration |> Map.update!(:creation_options, fn _ -> nil end)
  end
end
