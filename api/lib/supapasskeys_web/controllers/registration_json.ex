defmodule SupapasskeysWeb.RegistrationJSON do
  alias Supapasskeys.Passkeys.Registration

  @doc """
  Renders a single registration.
  """
  def show(%{registration: registration}) do
    data(registration)
  end

  defp data(%Registration{} = registration) do
    %{
      id: registration.id,
      creation_options: registration.creation_options
    }
  end
end
