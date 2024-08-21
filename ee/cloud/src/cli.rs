// © Copyright 2024 Cozy Bytes GmbH

use clap::{Parser, Subcommand};

use crate::app;

#[derive(Debug, Parser)]
#[command(about = "Easy Passkey authentication for Supabase and Postgres", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Debug, Subcommand)]
enum Commands {
    #[command(about = "Migrate the database schema")]
    Migrate,
}

pub async fn run() {
    let args = Cli::parse();
    match args.command {
        Some(Commands::Migrate) => println!("migrating database..."),
        None => app::run().await,
    }
}
