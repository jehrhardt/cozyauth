defmodule SupapasskeysWeb.PasskeyRegistrationController do
  use SupapasskeysWeb, :controller

  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.PasskeyRegistration

  action_fallback SupapasskeysWeb.FallbackController

  def index(conn, _params) do
    passkey_registriations = Passkeys.list_passkey_registriations()
    render(conn, :index, passkey_registriations: passkey_registriations)
  end

  def create(conn, %{"passkey_registration" => passkey_registration_params}) do
    with {:ok, %PasskeyRegistration{} = passkey_registration} <- Passkeys.create_passkey_registration(passkey_registration_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/passkey_registriations/#{passkey_registration}")
      |> render(:show, passkey_registration: passkey_registration)
    end
  end

  def show(conn, %{"id" => id}) do
    passkey_registration = Passkeys.get_passkey_registration!(id)
    render(conn, :show, passkey_registration: passkey_registration)
  end

  def update(conn, %{"id" => id, "passkey_registration" => passkey_registration_params}) do
    passkey_registration = Passkeys.get_passkey_registration!(id)

    with {:ok, %PasskeyRegistration{} = passkey_registration} <- Passkeys.update_passkey_registration(passkey_registration, passkey_registration_params) do
      render(conn, :show, passkey_registration: passkey_registration)
    end
  end

  def delete(conn, %{"id" => id}) do
    passkey_registration = Passkeys.get_passkey_registration!(id)

    with {:ok, %PasskeyRegistration{}} <- Passkeys.delete_passkey_registration(passkey_registration) do
      send_resp(conn, :no_content, "")
    end
  end
end
