use std::fs;

use serde::{Deserialize, Serialize};

const DEFAULT_CONFIG_FILE: &str = ".supapasskeys/config.toml";
const DEFAULT_DATABASE_URL: &str = "postgresql://postgres:postgres@localhost:54322/postgres";

#[derive(Serialize, Deserialize)]
pub(crate) struct Config {
    pub(crate) development: LocalConfig,
}

#[derive(Serialize, Deserialize)]
pub(crate) struct LocalConfig {
    pub(crate) database_url: String,
}

impl Config {
    pub(crate) fn new() -> Config {
        Config {
            development: LocalConfig {
                database_url: DEFAULT_DATABASE_URL.to_string(),
            },
        }
    }

    pub(crate) fn save(&self, config_file: Option<String>) -> Result<(), std::io::Error> {
        let file = match config_file {
            Some(config_file) => config_file,
            None => DEFAULT_CONFIG_FILE.to_string(),
        };
        match toml::to_string_pretty(self) {
            Ok(contents) => fs::write(file, contents),
            Err(_) => {
                eprintln!("Error writing config file: {}", file);
                std::process::exit(1);
            }
        }
    }

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
    use uuid::Uuid;

    use super::*;

    #[test]
    fn test_new() {
        let config = Config::new();
        assert_eq!(
            config.development.database_url,
            "postgresql://postgres:postgres@localhost:54322/postgres"
        );
    }

    #[test]
    fn test_save() {
        let config_name = Uuid::new_v4().to_string();
        let config = Config::new();
        let file = format!("./tests/config-{}.toml", config_name).to_string(); // "./tests/test_config.toml";
        config.save(Some(file.to_string())).unwrap();
        assert!(fs::metadata(file).is_ok());
    }

    #[test]
    fn test_load() {
        let config_name = Uuid::new_v4().to_string();
        let config_file = format!("./tests/config-{}.toml", config_name).to_string();
        let _ = Config::new().save(Some(config_file.to_string()));
        let config = Config::load(Some(config_file));
        assert_eq!(
            config.unwrap().development.database_url,
            "postgresql://postgres:postgres@localhost:54322/postgres"
        );
    }
}
