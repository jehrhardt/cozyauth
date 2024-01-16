defmodule SupapasskeysWeb.ServerLive.FormComponent do
  use SupapasskeysWeb, :live_component

  alias Supapasskeys.Passkeys

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage server records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="server-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:relying_party_name]} type="text" label="Relying party name" />
        <.input field={@form[:relying_party_origin]} type="text" label="Relying party origin" />
        <.input field={@form[:subdomain]} type="text" label="Subdomain" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Server</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{server: server} = assigns, socket) do
    changeset = Passkeys.change_server(server)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      socket.assigns.server
      |> Passkeys.change_server(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    save_server(socket, socket.assigns.action, server_params)
  end

  defp save_server(socket, :edit, server_params) do
    case Passkeys.update_server(socket.assigns.server, server_params) do
      {:ok, server} ->
        notify_parent({:saved, server})

        {:noreply,
         socket
         |> put_flash(:info, "Server updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_server(socket, :new, server_params) do
    case Passkeys.create_server(server_params) do
      {:ok, server} ->
        notify_parent({:saved, server})

        {:noreply,
         socket
         |> put_flash(:info, "Server created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
