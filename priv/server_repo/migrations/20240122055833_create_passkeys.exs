defmodule Supapasskeys.ServerRepo.Migrations.CreatePasskeys do
  use Ecto.Migration

  def change do
    execute "create table passkeys (
      id uuid not null default gen_random_uuid(),
      inserted_at timestamp with time zone not null default now(),
      updated_at timestamp with time zone not null default now(),
      key jsonb not null,
      constraint passkeys_pkey primary key (id)
    )"
  end
end
