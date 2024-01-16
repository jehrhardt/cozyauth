defmodule SupapasskeysWeb.RegistrationController do
  use SupapasskeysWeb, :controller

  alias Supapasskeys.WebAuthn.RelyingParty
  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration

  action_fallback SupapasskeysWeb.FallbackController

  def create(conn, user_params) do
    relying_party = %RelyingParty{
      name: get_req_header(conn, "x-supapasskeys-server-relying-party-name") |> List.first(),
      origin: get_req_header(conn, "x-supapasskeys-server-relying-party-origin") |> List.first()
    }

    with {:ok, %Registration{} = registration} <-
           Passkeys.create_registration(relying_party, user_params) do
      conn
      |> put_status(:ok)
      |> render(:show, registration: registration)
    end
  end

  def update(conn, %{"id" => id}) do
    # Read the body of the request as string
    {:ok, public_key_credential_json, conn} = Plug.Conn.read_body(conn)

    relying_party = %RelyingParty{
      name: get_req_header(conn, "x-supapasskeys-server-relying-party-name"),
      origin: get_req_header(conn, "x-supapasskeys-server-relying-party-origin")
    }

    registration = Passkeys.get_registration!(id)

    with {:ok, %Registration{} = registration} <-
           Passkeys.confirm_registration(relying_party, registration, public_key_credential_json) do
      render(conn, :confirmed, registration: registration)
    end
  end
end
