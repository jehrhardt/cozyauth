defmodule Supapasskeys.Servers do
  @moduledoc """
  The Servers context.
  """

  import Ecto.Query, warn: false
  alias Supapasskeys.ServerRepo, as: Repo

  alias Supapasskeys.Servers.Server

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
  def get_server_by_subdomain(subdomain) when is_binary(subdomain) do
    case Cachex.fetch(:servers, subdomain, fn ->
           {:commit, Repo.get_by(Server, subdomain: subdomain)}
         end) do
      {_, server} -> server
    end
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

  @doc """
  Migrates the database for a server.

  ## Examples

      iex> migrate_database(server)
      %Server{}

  """
  def migrate_database(%Server{} = server) do
    Supapasskeys.Repo.with_dynamic_repo(server, fn ->
      Ecto.Migrator.run(Supapasskeys.Repo, :up, all: true)
    end)

    change_server(server, %{migrated_at: DateTime.utc_now()})
    |> Repo.update()
  end
end
