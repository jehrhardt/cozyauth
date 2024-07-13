create table registrations (
    id uuid not null default gen_random_uuid(),
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    reg_state jsonb null,
    user_id uuid not null,
    confirmed_at timestamp with time zone null,
    constraint registrations_pkey primary key (id)
);
