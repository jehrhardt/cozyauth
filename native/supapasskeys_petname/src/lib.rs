use blake2::{
    digest::{Update, VariableOutput},
    Blake2bVar,
};
use petname::petname;
use rand::{distributions::Alphanumeric, thread_rng, Rng};

const SEPARATOR: &str = "-";
const HASH_LENGTH: usize = 4;

#[rustler::nif]
fn generate_subdomain() -> String {
    let name = petname(2, SEPARATOR);
    let hash = generate_hash();
    format!("{}{}{}", name, SEPARATOR, hash)
}

fn generate_hash() -> String {
    let random_bytes = thread_rng()
        .sample_iter(&Alphanumeric)
        .take(64)
        .collect::<Vec<u8>>();
    let mut hasher = Blake2bVar::new(HASH_LENGTH).unwrap();
    hasher.update(random_bytes.as_slice());
    let mut buffer = [0u8; HASH_LENGTH];
    hasher.finalize_variable(&mut buffer).unwrap();
    hex::encode(buffer)
}

rustler::init!("Elixir.Supapasskeys.Petname", [generate_subdomain]);
