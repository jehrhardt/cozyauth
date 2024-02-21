use std::fs;

use serde::{Deserialize, Serialize};

const DEFAULT_CONFIG_FILE: &str = ".supapasskeys/config.toml";

#[derive(Serialize, Deserialize)]
pub(crate) struct Config {
    pub(crate) development: LocalConfig,
}

#[derive(Serialize, Deserialize)]
pub(crate) struct LocalConfig {
    pub(crate) database_url: String,
}

impl Config {
    pub(crate) fn load(config_file: Option<String>) -> Option<Config> {
        let file = match config_file {
            Some(config_file) => config_file,
            None => DEFAULT_CONFIG_FILE.to_string(),
        };
        match fs::read_to_string(file) {
            Ok(contents) => match toml::from_str(&contents) {
                Ok(config) => Some(config),
                Err(e) => {
                    eprintln!("Error parsing config file: {}", e);
                    None
                }
            },
            Err(e) => {
                eprintln!("Error reading config file: {}", e);
                None
            }
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_load() {
        let config = Config::load(Some("./tests/test_config.toml".to_string()));
        assert_eq!(
            config.unwrap().development.database_url,
            "postgresql://postgres:postgres@localhost:5432/postgres"
        );
    }
}
