defmodule Supapasskeys.Servers do
  @moduledoc """
  The Servers context.
  """

  import Ecto.Query, warn: false
  alias Supapasskeys.Repo

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

  def migrate_server(%Server{
        user: user,
        password: password,
        host: host,
        database_name: database_name,
        port: port
      }) do
    default_dynamic_repo = Supapasskeys.ServerRepo.get_dynamic_repo()

    {:ok, repo} =
      Supapasskeys.ServerRepo.start_link(
        name: nil,
        username: user,
        password: password,
        hostname: host,
        database: database_name,
        port: port
      )

    try do
      Supapasskeys.ServerRepo.put_dynamic_repo(repo)
      Ecto.Migrator.run(Supapasskeys.ServerRepo, :up, all: true, prefix: :supapasskeys)
    after
      Supapasskeys.ServerRepo.put_dynamic_repo(default_dynamic_repo)
      Supervisor.stop(repo)
    end
  end
end
