defmodule Supapasskeys.SupabaseFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Supapasskeys.Supabase` context.
  """

  @doc """
  Generate a supabase_project.
  """
  def supabase_project_fixture(attrs \\ %{}) do
    {:ok, supabase_project} =
      attrs
      |> Enum.into(%{
        database_url: "some database_url",
        project_id: "some project_id"
      })
      |> Supapasskeys.Supabase.create_supabase_project()

    supabase_project
  end
end
