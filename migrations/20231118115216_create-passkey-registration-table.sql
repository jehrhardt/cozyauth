CREATE TABLE passkey_registrations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    state BYTEA NOT NULL
);
