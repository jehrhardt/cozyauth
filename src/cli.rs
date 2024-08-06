use clap::{Args, Parser, Subcommand};

use crate::{app::start_server, config::Settings, db::migrate};

#[derive(Debug, Parser)]
#[command(name = "cozyauth")]
#[command(about = "Easy Passkey authentication for Supabase and Postgres", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Debug, Subcommand)]
enum Commands {
    #[command(
        about = "Start the server",
        long_about = "Starts the server on a port configured via PORT environment variable or 3000 as default port."
    )]
    Server,
    Db(DbArgs),
}

#[derive(Debug, Args)]
#[command(flatten_help = true)]
struct DbArgs {
    #[command(subcommand)]
    command: DbCommands,
}

#[derive(Debug, Subcommand)]
enum DbCommands {
    #[command(
        about = "Manage the database schema",
        long_about = "Manage the database schema of the Postgres database configured via the DATABASE_URL variable.\n\
            An optional database schema name can be provided via the DATABASE_SCHEMA environment variable."
    )]
    Migrate,
}

pub async fn run() {
    let args = Cli::parse();
    let settings = Settings::from_env();
    match args.command {
        Commands::Server => start_server(settings).await,
        Commands::Db(db) => match db.command {
            DbCommands::Migrate => migrate(&settings).await,
        },
    }
}
