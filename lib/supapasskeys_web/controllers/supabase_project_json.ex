defmodule SupapasskeysWeb.SupabaseProjectJSON do
  alias Supapasskeys.Supabase.SupabaseProject

  @doc """
  Renders a list of supabase_projects.
  """
  def index(%{supabase_projects: supabase_projects}) do
    %{data: for(supabase_project <- supabase_projects, do: data(supabase_project))}
  end

  @doc """
  Renders a single supabase_project.
  """
  def show(%{supabase_project: supabase_project}) do
    %{data: data(supabase_project)}
  end

  defp data(%SupabaseProject{} = supabase_project) do
    %{
      id: supabase_project.id,
      project_id: supabase_project.project_id,
      database_url: supabase_project.database_url
    }
  end
end
