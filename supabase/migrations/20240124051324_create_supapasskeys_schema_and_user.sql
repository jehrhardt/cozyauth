create schema supapasskeys;

create role "supapasskeys" with login password 'supapasskeys';

grant create, usage on schema supapasskeys to supapasskeys;
