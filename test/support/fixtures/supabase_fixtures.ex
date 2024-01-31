defmodule Supapasskeys.SupabaseFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Supapasskeys.Supabase` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        database_url: "postgres://supapasskeys:supapasskeys@localhost:54329/postgres",
        name: "some name",
        reference_id: Faker.Internet.domain_word()
      })
      |> Supapasskeys.Supabase.create_project()

    {:ok, project} = Supapasskeys.Supabase.migrate_database(project)

    project
  end
end
