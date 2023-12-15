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
        database_url: "ecto://postgres:postgres@127.0.0.1:54322/postgres",
        project_id: :crypto.strong_rand_bytes(5) |> Base.url_encode64 |> String.slice(0..9)
      })
      |> Supapasskeys.Supabase.create_supabase_project()

    supabase_project
  end
end
