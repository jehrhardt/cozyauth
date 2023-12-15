defmodule SupapasskeysWeb.SupabaseProjectController do
  use SupapasskeysWeb, :controller

  alias Supapasskeys.Supabase
  alias Supapasskeys.Supabase.SupabaseProject

  action_fallback SupapasskeysWeb.FallbackController

  def index(conn, _params) do
    supabase_projects = Supabase.list_supabase_projects()
    render(conn, :index, supabase_projects: supabase_projects)
  end

  def create(conn, %{"supabase_project" => supabase_project_params}) do
    with {:ok, %SupabaseProject{} = supabase_project} <-
           Supabase.create_supabase_project(supabase_project_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/supabase_projects/#{supabase_project}")
      |> render(:show, supabase_project: supabase_project)
    end
  end

  def show(conn, %{"id" => id}) do
    supabase_project = Supabase.get_supabase_project!(id)
    render(conn, :show, supabase_project: supabase_project)
  end

  def update(conn, %{"id" => id, "supabase_project" => supabase_project_params}) do
    supabase_project = Supabase.get_supabase_project!(id)

    with {:ok, %SupabaseProject{} = supabase_project} <-
           Supabase.update_supabase_project(supabase_project, supabase_project_params) do
      render(conn, :show, supabase_project: supabase_project)
    end
  end

  def delete(conn, %{"id" => id}) do
    supabase_project = Supabase.get_supabase_project!(id)

    with {:ok, %SupabaseProject{}} <- Supabase.delete_supabase_project(supabase_project) do
      send_resp(conn, :no_content, "")
    end
  end
end
