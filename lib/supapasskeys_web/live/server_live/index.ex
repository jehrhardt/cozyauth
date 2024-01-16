defmodule SupapasskeysWeb.ServerLive.Index do
  use SupapasskeysWeb, :live_view

  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Server

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :servers, Passkeys.list_servers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Server")
    |> assign(:server, Passkeys.get_server!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Server")
    |> assign(:server, %Server{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Servers")
    |> assign(:server, nil)
  end

  @impl true
  def handle_info({SupapasskeysWeb.ServerLive.FormComponent, {:saved, server}}, socket) do
    {:noreply, stream_insert(socket, :servers, server)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    server = Passkeys.get_server!(id)
    {:ok, _} = Passkeys.delete_server(server)

    {:noreply, stream_delete(socket, :servers, server)}
  end
end
