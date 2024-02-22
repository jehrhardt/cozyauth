use clap::{Parser, Subcommand};

use crate::commands;

const DEFAULT_CONFIG_DIR: &str = "./.supapasskeys";

#[derive(Debug, Parser)]
#[command(about = "Supapasskeys extension for Supabase", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Debug, Subcommand)]
enum Commands {
    #[command(about = "Initialize Supapasskeys for this project", long_about = None)]
    Init,

    #[command(about = "Start local Supapasskeys instance and connect to Supabase", long_about = None)]
    Start,
}

pub fn start() {
    let cli = Cli::parse();
    match cli.command {
        Commands::Init => {
            let config_file = format!("{}/config.toml", DEFAULT_CONFIG_DIR);
            commands::init::run(config_file.as_str());
        }
        Commands::Start => commands::start::run(),
    }
}
