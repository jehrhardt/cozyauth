alter table registrations
add column passkey_id uuid;

alter table registrations
add constraint registrations_passkey_id_unique unique (passkey_id);

alter table registrations
add constraint registrations_passkey_id_fkey foreign key (passkey_id) references passkeys(id);
