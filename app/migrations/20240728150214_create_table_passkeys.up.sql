create table passkeys (
    id uuid not null default gen_random_uuid(),
    user_id uuid not null,
    credential_id bytea not null,
    credential jsonb not null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint passkeys_pkey primary key (id)
);
