defmodule Supapasskeys.Supabase do
  @moduledoc """
  The Supabase context.
  """

  import Ecto.Query, warn: false
  alias Supapasskeys.SupabaseRepo
  alias Supapasskeys.Repo

  alias Supapasskeys.Supabase.Project

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Gets a single project by reference_id.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project_by_reference_id!("123")
      %Project{}

      iex> get_project_by_reference_id!("456")
      ** (Ecto.NoResultsError)

  """
  def get_project_by_reference_id(reference_id) when is_binary(reference_id) do
    case Cachex.fetch(:supabase_projects, reference_id, fn ->
           {:commit, Repo.get_by(Project, reference_id: reference_id)}
         end) do
      {_, project} -> project
    end
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    case %Project{} |> Project.changeset(attrs) |> Repo.insert() do
      {:ok, project} ->
        Cachex.put(:supabase_projects, project.reference_id, project)
        {:ok, project}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    case project |> change_project(attrs) |> Repo.update() do
      {:ok, project} ->
        Cachex.put(:supabase_projects, project.reference_id, project)
        {:ok, project}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Cachex.del(:supabase_projects, project.reference_id)
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Migrates a project's database.

  ## Examples

      iex> migrate_project(project)
      {:ok, %Project{}}

      iex> migrate_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def migrate_database(%Project{} = project) do
    SupabaseRepo.with_dynamic_repo(project, fn ->
      Ecto.Migrator.run(SupabaseRepo, :up, all: true)
    end)

    change_project(project, %{migrated_at: DateTime.utc_now()})
    |> Repo.update()
  end
end
