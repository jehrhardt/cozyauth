defmodule Supapasskeys.ServerRepo.Migrations.GrantAccessToSupabaseRoles do
  use Ecto.Migration

  def change do
    execute "grant usage on schema supapasskeys to postgres, anon, authenticated, service_role"

    execute "grant select on all tables in schema supapasskeys to postgres, anon, authenticated, service_role"

    execute "grant execute on all functions in schema supapasskeys to postgres, anon, authenticated, service_role"

    execute "grant usage on all sequences in schema supapasskeys to postgres, anon, authenticated, service_role"
  end
end
