defmodule SupapasskeysWeb.RegistrationController do
  use SupapasskeysWeb, :controller

  alias Supapasskeys.Supabase
  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration

  action_fallback SupapasskeysWeb.FallbackController

  def create(conn, %{"relying_party_id" => relying_party_id} = params) do
    user_params = Map.take(params, ["id", "name", "display_name"])
    reference_id = get_req_header(conn, "x-supabase-reference-id") |> List.first()
    project = Supabase.get_project_by_reference_id(reference_id)
    relying_party = Passkeys.get_relying_party!(project, relying_party_id)

    with {:ok, %Registration{} = registration} <-
           Passkeys.create_registration(project, relying_party, user_params) do
      conn
      |> put_status(:ok)
      |> render(:show, registration: registration)
    end
  end

  def update(conn, %{"relying_party_id" => relying_party_id, "registration_id" => registration_id}) do
    # Read the body of the request as string
    {:ok, public_key_credential_json, conn} = Plug.Conn.read_body(conn)
    reference_id = get_req_header(conn, "x-supabase-reference-id") |> List.first()
    project = Supabase.get_project_by_reference_id(reference_id)
    relying_party = Passkeys.get_relying_party!(project, relying_party_id)
    registration = Passkeys.get_registration!(project, registration_id)

    with {:ok, %Registration{} = registration} <-
           Passkeys.confirm_registration(
             project,
             relying_party,
             registration,
             public_key_credential_json
           ) do
      render(conn, :confirmed, registration: registration)
    end
  end
end
