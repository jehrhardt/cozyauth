defmodule SupapasskeysWeb.PasskeyRegistrationJSON do
  alias Supapasskeys.Passkeys.PasskeyRegistration

  @doc """
  Renders a list of passkey_registriations.
  """
  def index(%{passkey_registriations: passkey_registriations}) do
    %{data: for(passkey_registration <- passkey_registriations, do: data(passkey_registration))}
  end

  @doc """
  Renders a single passkey_registration.
  """
  def show(%{passkey_registration: passkey_registration}) do
    %{data: data(passkey_registration)}
  end

  defp data(%PasskeyRegistration{} = passkey_registration) do
    %{
      id: passkey_registration.id,
      user_id: passkey_registration.user_id,
      state: passkey_registration.state
    }
  end
end
