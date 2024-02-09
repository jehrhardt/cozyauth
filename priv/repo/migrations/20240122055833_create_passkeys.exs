defmodule Supapasskeys.SupabaseRepo.Migrations.CreatePasskeys do
  use Ecto.Migration

  def change do
    execute "create table supapasskeys.passkeys (
      id uuid not null default gen_random_uuid(),
      user_id uuid not null,
      inserted_at timestamp with time zone not null default now(),
      updated_at timestamp with time zone not null default now(),
      key jsonb not null,
      constraint passkeys_pkey primary key (id)
    )"

    execute "create index if not exists passkeys_user_id_idx on supapasskeys.passkeys using btree (user_id)"
  end
end
