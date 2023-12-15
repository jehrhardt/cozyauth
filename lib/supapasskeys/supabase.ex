defmodule Supapasskeys.Supabase do
  @moduledoc """
  The Supabase context.
  """

  import Ecto.Query, warn: false
  alias Supapasskeys.Repo

  alias Supapasskeys.Supabase.SupabaseProject

  @doc """
  Returns the list of supabase_projects.

  ## Examples

      iex> list_supabase_projects()
      [%SupabaseProject{}, ...]

  """
  def list_supabase_projects do
    Repo.all(SupabaseProject)
  end

  @doc """
  Gets a single supabase_project.

  Raises `Ecto.NoResultsError` if the Supabase project does not exist.

  ## Examples

      iex> get_supabase_project!(123)
      %SupabaseProject{}

      iex> get_supabase_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_supabase_project!(id), do: Repo.get!(SupabaseProject, id)

  @doc """
  Creates a supabase_project.

  ## Examples

      iex> create_supabase_project(%{field: value})
      {:ok, %SupabaseProject{}}

      iex> create_supabase_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_supabase_project(attrs \\ %{}) do
    %SupabaseProject{}
    |> SupabaseProject.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a supabase_project.

  ## Examples

      iex> update_supabase_project(supabase_project, %{field: new_value})
      {:ok, %SupabaseProject{}}

      iex> update_supabase_project(supabase_project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_supabase_project(%SupabaseProject{} = supabase_project, attrs) do
    supabase_project
    |> SupabaseProject.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a supabase_project.

  ## Examples

      iex> delete_supabase_project(supabase_project)
      {:ok, %SupabaseProject{}}

      iex> delete_supabase_project(supabase_project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_supabase_project(%SupabaseProject{} = supabase_project) do
    Repo.delete(supabase_project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking supabase_project changes.

  ## Examples

      iex> change_supabase_project(supabase_project)
      %Ecto.Changeset{data: %SupabaseProject{}}

  """
  def change_supabase_project(%SupabaseProject{} = supabase_project, attrs \\ %{}) do
    SupabaseProject.changeset(supabase_project, attrs)
  end
end
