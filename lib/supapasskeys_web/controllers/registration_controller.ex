defmodule SupapasskeysWeb.RegistrationController do
  use SupapasskeysWeb, :controller

  alias Supapasskeys.Servers
  alias Supapasskeys.WebAuthn.RelyingParty
  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration

  action_fallback SupapasskeysWeb.FallbackController

  def create(conn, user_params) do
    relying_party = %RelyingParty{
      name: get_req_header(conn, "x-supapasskeys-server-relying-party-name") |> List.first(),
      origin: get_req_header(conn, "x-supapasskeys-server-relying-party-origin") |> List.first()
    }

    server_id = get_req_header(conn, "x-supapasskeys-server-id") |> List.first()

    with server <- Servers.get_server!(server_id),
         {:ok, %Registration{} = registration} <-
           Passkeys.create_registration(server, relying_party, user_params) do
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

    server_id = get_req_header(conn, "x-supapasskeys-server-id") |> List.first()

    with server <- Servers.get_server!(server_id),
         registration <- Passkeys.get_registration!(server, id),
         {:ok, %Registration{} = registration} <-
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
