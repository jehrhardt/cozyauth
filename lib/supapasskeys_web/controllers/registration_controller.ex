defmodule SupapasskeysWeb.RegistrationController do
  use SupapasskeysWeb, :controller

  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration

  action_fallback SupapasskeysWeb.FallbackController

  def create(conn, user_params) do
    with {:ok, %Registration{} = registration} <-
           Passkeys.create_registration(user_params) do
      conn
      |> put_status(:ok)
      |> render(:show, registration: registration)
    end
  end

  def update(conn, %{"id" => id}) do
    # Read the body of the request as string
    {:ok, public_key_credential_json, conn} = Plug.Conn.read_body(conn)
    registration = Passkeys.get_registration!(id)

    with {:ok, %Registration{} = registration} <-
           Passkeys.confirm_registration(registration, public_key_credential_json) do
      render(conn, :confirmed, registration: registration)
    end
  end
end
