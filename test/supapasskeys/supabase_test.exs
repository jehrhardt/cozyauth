defmodule Supapasskeys.SupabaseTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Supabase

  describe "supabase_projects" do
    alias Supapasskeys.Supabase.SupabaseProject

    import Supapasskeys.SupabaseFixtures

    @invalid_attrs %{project_id: nil, database_url: nil}

    test "list_supabase_projects/0 returns all supabase_projects" do
      supabase_project = supabase_project_fixture()
      assert Supabase.list_supabase_projects() == [supabase_project]
    end

    test "get_supabase_project!/1 returns the supabase_project with given id" do
      supabase_project = supabase_project_fixture()
      assert Supabase.get_supabase_project!(supabase_project.id) == supabase_project
    end

    test "create_supabase_project/1 with valid data creates a supabase_project" do
      valid_attrs = %{project_id: "some project_id", database_url: "some database_url"}

      assert {:ok, %SupabaseProject{} = supabase_project} =
               Supabase.create_supabase_project(valid_attrs)

      assert supabase_project.project_id == "some project_id"
      assert supabase_project.database_url == "some database_url"
    end

    test "create_supabase_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Supabase.create_supabase_project(@invalid_attrs)
    end

    test "update_supabase_project/2 with valid data updates the supabase_project" do
      supabase_project = supabase_project_fixture()

      update_attrs = %{
        project_id: "some updated project_id",
        database_url: "some updated database_url"
      }

      assert {:ok, %SupabaseProject{} = supabase_project} =
               Supabase.update_supabase_project(supabase_project, update_attrs)

      assert supabase_project.project_id == "some updated project_id"
      assert supabase_project.database_url == "some updated database_url"
    end

    test "update_supabase_project/2 with invalid data returns error changeset" do
      supabase_project = supabase_project_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Supabase.update_supabase_project(supabase_project, @invalid_attrs)

      assert supabase_project == Supabase.get_supabase_project!(supabase_project.id)
    end

    test "delete_supabase_project/1 deletes the supabase_project" do
      supabase_project = supabase_project_fixture()
      assert {:ok, %SupabaseProject{}} = Supabase.delete_supabase_project(supabase_project)

      assert_raise Ecto.NoResultsError, fn ->
        Supabase.get_supabase_project!(supabase_project.id)
      end
    end

    test "change_supabase_project/1 returns a supabase_project changeset" do
      supabase_project = supabase_project_fixture()
      assert %Ecto.Changeset{} = Supabase.change_supabase_project(supabase_project)
    end
  end
end
