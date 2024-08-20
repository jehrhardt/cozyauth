create table registrations (
    id uuid not null default gen_random_uuid(),
    user_id uuid not null,
    reg_state jsonb not null,
    expires_at timestamp with time zone not null,
    confirmed_at timestamp with time zone null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint registrations_pkey primary key (id)
);
