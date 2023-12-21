use clap::{Parser, Subcommand};

use crate::{
    app::{migrate_database, start_server},
    config::load_config,
};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Migrate,
    Serve,
}

pub async fn run() {
    let cli = Cli::parse();
    let config = load_config("dev");
    match cli.command {
        Commands::Migrate => migrate_database(config).await,
        Commands::Serve => start_server(config).await,
    }
}
