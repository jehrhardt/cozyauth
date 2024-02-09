defmodule SupapasskeysWeb.RegistrationController do
  use SupapasskeysWeb, :controller

  alias Supapasskeys.Servers
  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration

  action_fallback SupapasskeysWeb.FallbackController

  def create(conn, %{"relying_party_id" => relying_party_id} = params) do
    user_params = Map.take(params, ["id", "name", "display_name"])
    subdomain = get_req_header(conn, "x-supabase-reference-id") |> List.first()
    server = Servers.get_server_by_subdomain(subdomain)
    relying_party = Passkeys.get_relying_party!(server, relying_party_id)

    with {:ok, %Registration{} = registration} <-
           Passkeys.create_registration(server, relying_party, user_params) do
      conn
      |> put_status(:ok)
      |> render(:show, registration: registration)
    end
  end

  def update(conn, %{"relying_party_id" => relying_party_id, "registration_id" => registration_id}) do
    # Read the body of the request as string
    {:ok, public_key_credential_json, conn} = Plug.Conn.read_body(conn)
    subdomain = get_req_header(conn, "x-supabase-reference-id") |> List.first()
    server = Servers.get_server_by_subdomain(subdomain)
    relying_party = Passkeys.get_relying_party!(server, relying_party_id)
    registration = Passkeys.get_registration!(server, registration_id)

    with {:ok, %Registration{} = registration} <-
           Passkeys.confirm_registration(
             server,
             relying_party,
             registration,
             public_key_credential_json
           ) do
      render(conn, :confirmed, registration: registration)
    end
  end
end
