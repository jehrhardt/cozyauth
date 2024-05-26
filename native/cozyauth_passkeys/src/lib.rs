#[rustler::nif]
fn start_passkey_registration() -> String {
    "Hello world!".to_string()
}

rustler::init!("Elixir.Cozyauth.Passkeys", [start_passkey_registration]);
