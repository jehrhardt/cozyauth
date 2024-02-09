defmodule Supapasskeys.SupabaseRepo.Migrations.CreateRelyingParty do
  use Ecto.Migration

  def change do
    execute "create table supapasskeys.relying_parties (
      id uuid not null default gen_random_uuid(),
      name character varying not null,
      origin character varying not null,
      inserted_at timestamp with time zone not null default now(),
      updated_at timestamp with time zone not null default now(),
      constraint relying_parties_pkey primary key (id)
    )"

    execute "alter table supapasskeys.registrations
    add column if not exists relying_party_id uuid not null,
    add constraint registrations_relying_party_id_fkey foreign key (relying_party_id) references supapasskeys.relying_parties (id) on delete cascade"

    execute "create index if not exists registrations_relying_party_id_idx on supapasskeys.registrations using btree (relying_party_id)"

    execute "alter table supapasskeys.passkeys
    add column if not exists relying_party_id uuid not null,
    add constraint passkeys_relying_party_id_fkey foreign key (relying_party_id) references supapasskeys.relying_parties (id) on delete cascade"

    execute "create index if not exists passkeys_relying_party_id_idx on supapasskeys.passkeys using btree (relying_party_id)"
  end
end
