defmodule SupapasskeysWeb.RegistrationController do
  use SupapasskeysWeb, :controller

  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration

  action_fallback SupapasskeysWeb.FallbackController

  def index(conn, _params) do
    registrations = Passkeys.list_registrations()
    render(conn, :index, registrations: registrations)
  end

  def create(conn, %{"registration" => registration_params}) do
    with {:ok, %Registration{} = registration} <-
           Passkeys.create_registration(registration_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/registrations/#{registration}")
      |> render(:show, registration: registration)
    end
  end

  def show(conn, %{"id" => id}) do
    registration = Passkeys.get_registration!(id)
    render(conn, :show, registration: registration)
  end

  def update(conn, %{"id" => id, "registration" => registration_params}) do
    registration = Passkeys.get_registration!(id)

    with {:ok, %Registration{} = registration} <-
           Passkeys.update_registration(registration, registration_params) do
      render(conn, :show, registration: registration)
    end
  end

  def delete(conn, %{"id" => id}) do
    registration = Passkeys.get_registration!(id)

    with {:ok, %Registration{}} <- Passkeys.delete_registration(registration) do
      send_resp(conn, :no_content, "")
    end
  end
end
