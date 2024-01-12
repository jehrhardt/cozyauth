defmodule SupapasskeysWeb.RegistrationJSON do
  @doc """
  Renders a single registration.
  """
  def show(%{registration: registration}) do
    %{
      id: registration.id,
      creation_options: registration.creation_options
    }
  end

  @doc """
  Renders a confirmed registration.
  """
  def confirmed(%{registration: registration}) do
    %{
      id: registration.id,
      confirmed_at: registration.confirmed_at
    }
  end
end
