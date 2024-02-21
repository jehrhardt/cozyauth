use crate::config::Config;

pub(crate) fn run(config: Config) {
    println!("{}", config.development.database_url);
}
