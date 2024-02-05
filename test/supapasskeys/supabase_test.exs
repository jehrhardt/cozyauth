defmodule Supapasskeys.SupabaseTest do
  use Supapasskeys.DataCase

  alias Supapasskeys.Supabase

  describe "projects" do
    alias Supapasskeys.Supabase.Project

    import Supapasskeys.SupabaseFixtures

    @invalid_attrs %{name: nil, reference_id: nil, database_url: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Supabase.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Supabase.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{
        name: "some name",
        reference_id: "some reference_id",
        database_url: "some database_url"
      }

      assert {:ok, %Project{} = project} = Supabase.create_project(valid_attrs)
      assert project.name == "some name"
      assert project.reference_id == "some reference_id"
      assert project.database_url == "some database_url"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Supabase.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()

      update_attrs = %{
        name: "some updated name",
        reference_id: "some updated reference_id",
        database_url: "some updated database_url"
      }

      assert {:ok, %Project{} = project} = Supabase.update_project(project, update_attrs)
      assert project.name == "some updated name"
      assert project.reference_id == "some updated reference_id"
      assert project.database_url == "some updated database_url"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Supabase.update_project(project, @invalid_attrs)
      assert project == Supabase.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Supabase.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Supabase.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Supabase.change_project(project)
    end
  end
end
