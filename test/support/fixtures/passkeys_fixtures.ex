defmodule Supapasskeys.PasskeysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Supapasskeys.Passkeys` context.
  """

  @doc """
  Generate a registration.
  """
  def registration_fixture(relying_party, attrs \\ %{}) do
    user =
      attrs
      |> Enum.into(%{
        id: Faker.UUID.v4(),
        name: Faker.Internet.email(),
        display_name: Faker.Person.name()
      })

    {:ok, registration} = Supapasskeys.Passkeys.create_registration(relying_party, user)
    registration |> Map.update!(:creation_options, fn _ -> nil end)
  end

  @doc """
  Generate a server.
  """
  def server_fixture(attrs \\ %{}) do
    {:ok, server} =
      attrs
      |> Enum.into(%{
        relying_party_name: Faker.Company.name(),
        relying_party_origin: "https://#{Faker.Internet.domain_name()}",
        subdomain: Faker.Internet.domain_word()
      })
      |> Supapasskeys.Passkeys.create_server()

    server
  end
end
