defmodule SupapasskeysWeb.ProjectLive.Index do
  use SupapasskeysWeb, :live_view

  alias Supapasskeys.Supabase
  alias Supapasskeys.Supabase.Project

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :projects, Supabase.list_projects())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Supabase.get_project!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_info({SupapasskeysWeb.ProjectLive.FormComponent, {:saved, project}}, socket) do
    {:noreply, stream_insert(socket, :projects, project)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Supabase.get_project!(id)
    {:ok, _} = Supabase.delete_project(project)

    {:noreply, stream_delete(socket, :projects, project)}
  end
end
