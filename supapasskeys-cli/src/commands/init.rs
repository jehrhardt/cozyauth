use crate::config::Config;

pub(crate) fn run(config_dir: &str) {
    let config = Config::new();
    let _ = config.save(Some(config_dir.to_string()));
}

#[cfg(test)]
mod test {
    use uuid::Uuid;

    use super::*;

    #[test]
    fn test_run() {
        let config_name = Uuid::new_v4().to_string();
        let file = format!("./tests/config-{}.toml", config_name);
        run(file.as_str());
        let config = Config::load(Some(file)).unwrap();
        assert_eq!(
            config.development.database_url,
            "postgresql://postgres:postgres@localhost:54322/postgres"
        );
    }
}
