defmodule Supapasskeys.Passkeys do
  @moduledoc """
  The Passkeys context.
  """

  import Ecto.Query, warn: false
  alias Supapasskeys.Supabase.Project
  alias Supapasskeys.WebAuthn
  alias Supapasskeys.SupabaseRepo
  alias Supapasskeys.Passkeys.Registration
  alias Supapasskeys.Passkeys.RelyingParty
  alias Supapasskeys.Passkeys.User

  @doc """
  Gets a single registration.

  Raises `Ecto.NoResultsError` if the Registration does not exist.

  ## Examples

      iex> get_registration!(%Project{}, 123)
      %Registration{}

      iex> get_registration!(%Project{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_registration!(%Project{} = project, id) do
    SupabaseRepo.with_dynamic_repo(project, fn ->
      SupabaseRepo.get!(Registration, id)
    end)
  end

  @doc """
  Creates a registration.

  ## Examples

      iex> create_registration(%Project{}, %RelyingParty{}, %{field: value})
      {:ok, %Registration{}}

      iex> create_registration(%Project{}, %RelyingParty{},, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration(
        %Project{} = project,
        %RelyingParty{name: name, origin: origin} = relying_party,
        attrs \\ %{}
      ) do
    webauthn_relying_party = %WebAuthn.RelyingParty{name: name, origin: origin}

    %User{}
    |> User.changeset(attrs)
    |> User.to_webauthn_user()
    |> case do
      {:ok, user} ->
        {creation_options_json, state_json} =
          WebAuthn.start_passkey_registration(user, webauthn_relying_party)

        SupabaseRepo.with_dynamic_repo(project, fn ->
          relying_party
          |> Ecto.build_assoc(:registrations, state: state_json, user_id: user.id)
          |> SupabaseRepo.insert()
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

      iex> update_registration(%Project{}, %Registration{}, %{field: new_value})
      {:ok, %Registration{}}

      iex> update_registration(%Project{}, %Registration{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registration(%Project{} = project, %Registration{} = registration, attrs) do
    SupabaseRepo.with_dynamic_repo(project, fn ->
      registration
      |> Registration.changeset(attrs)
      |> SupabaseRepo.update()
    end)
  end

  @doc """
  Confirms a registration.

  ## Examples

      iex> confirm_registration(%Project{}, %RelyingParty{}, %Registration{}, public_key_credentials_json)
      {:ok, %Registration{}}

      iex> confirm_registration(%Project{}, %RelyingParty{}, %Registration{}, public_key_credentials_json)
      {:error, %Ecto.Changeset{}}

  """
  def confirm_registration(
        %Project{} = project,
        %RelyingParty{name: name, origin: origin},
        %Registration{} = registration,
        public_key_credentials_json
      ) do
    _passkey =
      WebAuthn.finish_passkey_registration(
        public_key_credentials_json,
        registration.state,
        %WebAuthn.RelyingParty{name: name, origin: origin}
      )

    update_registration(project, registration, %{state: nil, confirmed_at: DateTime.utc_now()})
  end

  @doc """
  Returns the list of relying_parties.

  ## Examples

      iex> list_relying_parties(%Project{})
      [%RelyingParty{}, ...]

  """
  def list_relying_parties(%Project{} = project) do
    SupabaseRepo.with_dynamic_repo(project, fn ->
      SupabaseRepo.all(RelyingParty)
    end)
  end

  @doc """
  Gets a single relying_party.

  Raises `Ecto.NoResultsError` if the Relying party does not exist.

  ## Examples

      iex> get_relying_party!(%Project{}, 123)
      %RelyingParty{}

      iex> get_relying_party!(%Project{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_relying_party!(%Project{} = project, id),
    do:
      SupabaseRepo.with_dynamic_repo(project, fn ->
        SupabaseRepo.get!(RelyingParty, id)
      end)

  @doc """
  Creates a relying_party.

  ## Examples

      iex> create_relying_party(%Project{}, %{field: value})
      {:ok, %RelyingParty{}}

      iex> create_relying_party(%Project{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_relying_party(%Project{} = project, attrs \\ %{}) do
    SupabaseRepo.with_dynamic_repo(project, fn ->
      %RelyingParty{}
      |> RelyingParty.changeset(attrs)
      |> SupabaseRepo.insert()
    end)
  end

  @doc """
  Updates a relying_party.

  ## Examples

      iex> update_relying_party(%Project{}, relying_party, %{field: new_value})
      {:ok, %RelyingParty{}}

      iex> update_relying_party(%Project{}, relying_party, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_relying_party(%Project{} = project, %RelyingParty{} = relying_party, attrs) do
    SupabaseRepo.with_dynamic_repo(project, fn ->
      relying_party
      |> RelyingParty.changeset(attrs)
      |> SupabaseRepo.update()
    end)
  end

  @doc """
  Deletes a relying_party.

  ## Examples

      iex> delete_relying_party(%Project{}, relying_party)
      {:ok, %RelyingParty{}}

      iex> delete_relying_party(%Project{}, relying_party)
      {:error, %Ecto.Changeset{}}

  """
  def delete_relying_party(%Project{} = project, %RelyingParty{} = relying_party) do
    SupabaseRepo.with_dynamic_repo(project, fn ->
      SupabaseRepo.delete(relying_party)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking relying_party changes.

  ## Examples

      iex> change_relying_party(relying_party)
      %Ecto.Changeset{data: %RelyingParty{}}

  """
  def change_relying_party(%RelyingParty{} = relying_party, attrs \\ %{}) do
    RelyingParty.changeset(relying_party, attrs)
  end
end
