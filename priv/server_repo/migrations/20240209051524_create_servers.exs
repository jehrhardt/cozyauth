defmodule Supapasskeys.ServerRepo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    execute "create table servers (
      id uuid not null default gen_random_uuid(),
      subdomain character varying not null,
      database_url character varying not null,
      migrated_at timestamp with time zone null,
      inserted_at timestamp with time zone not null default now(),
      updated_at timestamp with time zone not null default now(),
      constraint projects_pkey primary key (id),
      constraint projects_subdomain_key unique (subdomain)
    )"
  end
end
