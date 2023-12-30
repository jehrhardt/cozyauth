defmodule SupapasskeysWeb.RegistrationJSON do
  alias Supapasskeys.Passkeys.Registration

  @doc """
  Renders a list of registrations.
  """
  def index(%{registrations: registrations}) do
    %{data: for(registration <- registrations, do: data(registration))}
  end

  @doc """
  Renders a single registration.
  """
  def show(%{registration: registration}) do
    %{data: data(registration)}
  end

  defp data(%Registration{} = registration) do
    %{
      id: registration.id,
      user_id: registration.user_id,
      state: registration.state
    }
  end
end
