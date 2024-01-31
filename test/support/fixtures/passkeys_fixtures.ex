defmodule Supapasskeys.PasskeysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Supapasskeys.Passkeys` context.
  """

  @doc """
  Generate a registration.
  """
  def registration_fixture(project, relying_party, attrs \\ %{}) do
    user =
      attrs
      |> Enum.into(%{
        id: Faker.UUID.v4(),
        name: Faker.Internet.email(),
        display_name: Faker.Person.name()
      })

    {:ok, registration} = Supapasskeys.Passkeys.create_registration(project, relying_party, user)
    registration |> Map.update!(:creation_options, fn _ -> nil end)
  end

  @doc """
  Generate a relying_party.
  """
  def relying_party_fixture(project, attrs \\ %{}) do
    relying_party_params =
      attrs
      |> Enum.into(%{
        name: Faker.Company.name(),
        origin: "https://#{Faker.Internet.domain_name()}"
      })

    {:ok, relying_party} =
      Supapasskeys.Passkeys.create_relying_party(project, relying_party_params)

    relying_party
  end
end
