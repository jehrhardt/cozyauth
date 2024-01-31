defmodule Supapasskeys.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    execute "create table projects (
      id uuid not null default gen_random_uuid(),
      name character varying not null,
      reference_id character varying not null,
      database_url character varying not null,
      migrated_at timestamp with time zone null,
      inserted_at timestamp with time zone not null default now(),
      updated_at timestamp with time zone not null default now(),
      constraint projects_pkey primary key (id),
      constraint projects_reference_id_key unique (reference_id)
    )"
  end
end
