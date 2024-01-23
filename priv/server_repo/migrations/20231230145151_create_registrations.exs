defmodule Supapasskeys.ServerRepo.Migrations.CreateRegistrations do
  use Ecto.Migration

  def change do
    execute "create table registrations (
      id uuid not null default gen_random_uuid(),
      inserted_at timestamp with time zone not null default now(),
      updated_at timestamp with time zone not null default now(),
      user_id uuid not null,
      state jsonb null,
      confirmed_at timestamp with time zone null,
      constraint registrations_pkey primary key (id)
    )"
  end
end
