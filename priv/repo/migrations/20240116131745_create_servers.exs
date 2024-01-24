defmodule Supapasskeys.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    execute "create table servers (
      id uuid not null default gen_random_uuid(),
      inserted_at timestamp with time zone not null default now(),
      updated_at timestamp with time zone not null default now(),
      relying_party_name character varying not null,
      relying_party_origin character varying not null,
      subdomain character varying not null,
      \"user\" character varying null,
      password character varying not null,
      host character varying not null,
      database_name character varying null,
      port integer null,
      migrated_at timestamp with time zone null,
      constraint servers_pkey primary key (id),
      constraint servers_subdomain_key unique (subdomain)
    )"
  end
end
