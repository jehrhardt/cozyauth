defmodule Supapasskeys.Passkeys do
  @moduledoc """
  The Passkeys context.
  """

  import Ecto.Query, warn: false
  alias Supapasskeys.Servers.Server
  alias Supapasskeys.WebAuthn.RelyingParty
  alias Supapasskeys.WebAuthn
  alias Supapasskeys.ServerRepo

  alias Supapasskeys.Passkeys.Registration
  alias Supapasskeys.Passkeys.User

  @doc """
  Gets a single registration.

  Raises `Ecto.NoResultsError` if the Registration does not exist.

  ## Examples

      iex> get_registration!(%Server{}, 123)
      %Registration{}

      iex> get_registration!(%Server{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_registration!(%Server{} = server, id) do
    ServerRepo.with_dynamic_repo(server, fn ->
      ServerRepo.get!(Registration, id)
    end)
  end

  @doc """
  Creates a registration.

  ## Examples

      iex> create_registration(%Server{}, %{field: value})
      {:ok, %Registration{}}

      iex> create_registration(%Server{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration(%Server{} = server, %RelyingParty{} = relying_party, attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> User.to_webauthn_user()
    |> case do
      {:ok, user} ->
        {creation_options_json, state_json} =
          WebAuthn.start_passkey_registration(user, relying_party)

        ServerRepo.with_dynamic_repo(server, fn ->
          %Registration{}
          |> Registration.changeset(
            %{}
            |> Map.put(:state, state_json)
            |> Map.put(:user_id, user.id)
          )
          |> ServerRepo.insert()
          |> case do
            {:ok, registration} ->
              {:ok, registration |> Map.put(:creation_options, creation_options_json)}
          end
        end)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a registration.

  ## Examples

      iex> update_registration(%Server{}, %Registration{}, %{field: new_value})
      {:ok, %Registration{}}

      iex> update_registration(%Server{}, %Registration{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registration(%Server{} = server, %Registration{} = registration, attrs) do
    ServerRepo.with_dynamic_repo(server, fn ->
      registration
      |> Registration.changeset(attrs)
      |> ServerRepo.update()
    end)
  end

  @doc """
  Confirms a registration.

  ## Examples

      iex> confirm_registration(%Server{}, %RelyingParty{}, %Registration{}, public_key_credentials_json)
      {:ok, %Registration{}}

      iex> confirm_registration(%Server{}, %RelyingParty{}, %Registration{}, public_key_credentials_json)
      {:error, %Ecto.Changeset{}}

  """
  def confirm_registration(
        %Server{} = server,
        %RelyingParty{} = relying_party,
        %Registration{} = registration,
        public_key_credentials_json
      ) do
    _passkey =
      WebAuthn.finish_passkey_registration(
        public_key_credentials_json,
        registration.state,
        relying_party
      )

    update_registration(server, registration, %{state: nil, confirmed_at: DateTime.utc_now()})
  end
end
