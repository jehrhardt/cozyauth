defmodule Supapasskeys.Passkeys do
  @moduledoc """
  The Passkeys context.
  """

  import Ecto.Query, warn: false
  alias Supapasskeys.WebAuthn
  alias Supapasskeys.Repo

  alias Supapasskeys.Passkeys.Registration
  alias Supapasskeys.Passkeys.User

  @doc """
  Returns the list of registrations.

  ## Examples

      iex> list_registrations()
      [%Registration{}, ...]

  """
  def list_registrations do
    Repo.all(Registration)
  end

  @doc """
  Gets a single registration.

  Raises `Ecto.NoResultsError` if the Registration does not exist.

  ## Examples

      iex> get_registration!(123)
      %Registration{}

      iex> get_registration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_registration!(id), do: Repo.get!(Registration, id)

  @doc """
  Creates a registration.

  ## Examples

      iex> create_registration(%{field: value})
      {:ok, %Registration{}}

      iex> create_registration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> User.to_webauthn_user()
    |> case do
      {:ok, user} ->
        {creation_options_json, state_json} =
          WebAuthn.start_passkey_registration(user, load_relying_party())

        %Registration{}
        |> Registration.changeset(
          %{}
          |> Map.put(:state, state_json)
          |> Map.put(:user_id, user.id)
        )
        |> Repo.insert()
        |> case do
          {:ok, registration} ->
            {:ok, registration |> Map.put(:creation_options, creation_options_json)}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a registration.

  ## Examples

      iex> update_registration(registration, %{field: new_value})
      {:ok, %Registration{}}

      iex> update_registration(registration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registration(%Registration{} = registration, attrs) do
    registration
    |> Registration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Confirms a registration.

  ## Examples

      iex> confirm_registration(registration, public_key_credentials_json)
      {:ok, %Registration{}}

      iex> confirm_registration(registration, public_key_credentials_json)
      {:error, %Ecto.Changeset{}}

  """
  def confirm_registration(%Registration{} = registration, public_key_credentials_json) do
    _passkey =
      WebAuthn.finish_passkey_registration(
        public_key_credentials_json,
        registration.state,
        load_relying_party()
      )

    update_registration(registration, %{state: nil, confirmed_at: DateTime.utc_now()})
  end

  @doc """
  Deletes a registration.

  ## Examples

      iex> delete_registration(registration)
      {:ok, %Registration{}}

      iex> delete_registration(registration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_registration(%Registration{} = registration) do
    Repo.delete(registration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration changes.

  ## Examples

      iex> change_registration(registration)
      %Ecto.Changeset{data: %Registration{}}

  """
  def change_registration(%Registration{} = registration, attrs \\ %{}) do
    Registration.changeset(registration, attrs)
  end

  defp load_relying_party() do
    relying_party_config = Application.get_env(:supapasskeys, Supapasskeys.Passkeys)

    %WebAuthn.RelyingParty{
      name: relying_party_config[:relying_party_name],
      origin: relying_party_config[:relying_party_origin]
    }
  end
end
