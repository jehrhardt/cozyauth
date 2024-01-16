defmodule Supapasskeys.Passkeys do
  @moduledoc """
  The Passkeys context.
  """

  import Ecto.Query, warn: false
  alias Supapasskeys.WebAuthn.RelyingParty
  alias Supapasskeys.WebAuthn
  alias Supapasskeys.Repo

  alias Supapasskeys.Passkeys.Registration
  alias Supapasskeys.Passkeys.User
  alias Supapasskeys.Passkeys.Server

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
  def create_registration(%RelyingParty{} = relying_party, attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> User.to_webauthn_user()
    |> case do
      {:ok, user} ->
        {creation_options_json, state_json} =
          WebAuthn.start_passkey_registration(user, relying_party)

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
  def confirm_registration(
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

    update_registration(registration, %{state: nil, confirmed_at: DateTime.utc_now()})
  end

  @doc """
  Returns the list of servers.

  ## Examples

      iex> list_servers()
      [%Server{}, ...]

  """
  def list_servers do
    Repo.all(Server)
  end

  @doc """
  Gets a single server.

  Raises `Ecto.NoResultsError` if the Server does not exist.

  ## Examples

      iex> get_server!(123)
      %Server{}

      iex> get_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_server!(id), do: Repo.get!(Server, id)

  @doc """
  Gets a single server by subdomain.

  ## Examples

      iex> get_server_by_subdomain("subdomain")
      %Server{}

      iex> get_server_by_subdomain("subdomain")
      nil

  """
  def get_server_by_subdomain(subdomain) do
    Repo.get_by(Server, subdomain: subdomain)
  end

  @doc """
  Creates a server.

  ## Examples

      iex> create_server(%{field: value})
      {:ok, %Server{}}

      iex> create_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_server(attrs \\ %{}) do
    %Server{}
    |> Server.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server.

  ## Examples

      iex> update_server(server, %{field: new_value})
      {:ok, %Server{}}

      iex> update_server(server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server.

  ## Examples

      iex> delete_server(server)
      {:ok, %Server{}}

      iex> delete_server(server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_server(%Server{} = server) do
    Repo.delete(server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server changes.

  ## Examples

      iex> change_server(server)
      %Ecto.Changeset{data: %Server{}}

  """
  def change_server(%Server{} = server, attrs \\ %{}) do
    Server.changeset(server, attrs)
  end
end
