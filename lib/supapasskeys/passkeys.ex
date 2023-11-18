defmodule Supapasskeys.Passkeys do
  @moduledoc """
  The Passkeys context.
  """

  import Ecto.Query, warn: false
  alias Supapasskeys.Repo

  alias Supapasskeys.Passkeys.PasskeyRegistration

  @doc """
  Returns the list of passkey_registriations.

  ## Examples

      iex> list_passkey_registriations()
      [%PasskeyRegistration{}, ...]

  """
  def list_passkey_registriations do
    Repo.all(PasskeyRegistration)
  end

  @doc """
  Gets a single passkey_registration.

  Raises `Ecto.NoResultsError` if the Passkey registration does not exist.

  ## Examples

      iex> get_passkey_registration!(123)
      %PasskeyRegistration{}

      iex> get_passkey_registration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_passkey_registration!(id), do: Repo.get!(PasskeyRegistration, id)

  @doc """
  Creates a passkey_registration.

  ## Examples

      iex> create_passkey_registration(%{field: value})
      {:ok, %PasskeyRegistration{}}

      iex> create_passkey_registration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_passkey_registration(attrs \\ %{}) do
    %PasskeyRegistration{}
    |> PasskeyRegistration.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a passkey_registration.

  ## Examples

      iex> update_passkey_registration(passkey_registration, %{field: new_value})
      {:ok, %PasskeyRegistration{}}

      iex> update_passkey_registration(passkey_registration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_passkey_registration(%PasskeyRegistration{} = passkey_registration, attrs) do
    passkey_registration
    |> PasskeyRegistration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a passkey_registration.

  ## Examples

      iex> delete_passkey_registration(passkey_registration)
      {:ok, %PasskeyRegistration{}}

      iex> delete_passkey_registration(passkey_registration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_passkey_registration(%PasskeyRegistration{} = passkey_registration) do
    Repo.delete(passkey_registration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking passkey_registration changes.

  ## Examples

      iex> change_passkey_registration(passkey_registration)
      %Ecto.Changeset{data: %PasskeyRegistration{}}

  """
  def change_passkey_registration(%PasskeyRegistration{} = passkey_registration, attrs \\ %{}) do
    PasskeyRegistration.changeset(passkey_registration, attrs)
  end
end
