alter table registrations
drop constraint if exists registrations_passkey_id_fkey;

alter table registrations
drop constraint if exists registrations_passkey_id_unique;


alter table registrations
drop column if exists passkey_id;
