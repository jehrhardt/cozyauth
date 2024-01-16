defmodule SupapasskeysWeb.ServerLive.Show do
  use SupapasskeysWeb, :live_view

  alias Supapasskeys.Passkeys

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:server, Passkeys.get_server!(id))}
  end

  defp page_title(:show), do: "Show Server"
  defp page_title(:edit), do: "Edit Server"
end
