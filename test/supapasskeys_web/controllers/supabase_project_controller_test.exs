defmodule SupapasskeysWeb.SupabaseProjectControllerTest do
  use SupapasskeysWeb.ConnCase

  import Supapasskeys.SupabaseFixtures

  alias Supapasskeys.Supabase.SupabaseProject

  @create_attrs %{
    project_id: "some project_id",
    database_url: "some database_url"
  }
  @update_attrs %{
    project_id: "some updated project_id",
    database_url: "some updated database_url"
  }
  @invalid_attrs %{project_id: nil, database_url: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all supabase_projects", %{conn: conn} do
      conn = get(conn, ~p"/supabase/projects")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create supabase_project" do
    test "renders supabase_project when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/supabase/projects", supabase_project: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/supabase/projects/#{id}")

      assert %{
               "id" => ^id,
               "database_url" => "some database_url",
               "project_id" => "some project_id"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/supabase/projects", supabase_project: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update supabase_project" do
    setup [:create_supabase_project]

    test "renders supabase_project when data is valid", %{
      conn: conn,
      supabase_project: %SupabaseProject{id: id} = supabase_project
    } do
      conn =
        put(conn, ~p"/supabase/projects/#{supabase_project}", supabase_project: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/supabase/projects/#{id}")

      assert %{
               "id" => ^id,
               "database_url" => "some updated database_url",
               "project_id" => "some updated project_id"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, supabase_project: supabase_project} do
      conn =
        put(conn, ~p"/supabase/projects/#{supabase_project}", supabase_project: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete supabase_project" do
    setup [:create_supabase_project]

    test "deletes chosen supabase_project", %{conn: conn, supabase_project: supabase_project} do
      conn = delete(conn, ~p"/supabase/projects/#{supabase_project}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/supabase/projects/#{supabase_project}")
      end
    end
  end

  defp create_supabase_project(_) do
    supabase_project = supabase_project_fixture()
    %{supabase_project: supabase_project}
  end
end
