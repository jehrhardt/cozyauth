defmodule SupapasskeysWeb.RegistrationController do
  use SupapasskeysWeb, :controller

  alias Supapasskeys.Passkeys
  alias Supapasskeys.Passkeys.Registration

  action_fallback SupapasskeysWeb.FallbackController

  def create(conn, %{"registration" => user_params}) do
    with {:ok, %Registration{} = registration} <-
           Passkeys.create_registration(user_params) do
      conn
      |> put_status(:ok)
      |> render(:show, registration: registration)
    end
  end

  def update(conn, %{"id" => id, "registration" => registration_params}) do
    registration = Passkeys.get_registration!(id)

    with {:ok, %Registration{} = registration} <-
           Passkeys.update_registration(registration, registration_params) do
      render(conn, :show, registration: registration)
    end
  end
end
