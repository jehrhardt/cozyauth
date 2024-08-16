use clap::{Args, Parser, Subcommand};

#[derive(Debug, Parser)]
#[command(about = "Easy Passkey authentication for Supabase and Postgres", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Debug, Subcommand)]
enum Commands {
    #[command()]
    Run(RunArgs),
}

#[derive(Debug, Args)]
#[command(flatten_help = true)]
struct RunArgs {
    #[command(subcommand)]
    command: RunCommands,
}

#[derive(Debug, Subcommand)]
enum RunCommands {
    #[command()]
    Dev,
}

pub async fn run() {
    let args = Cli::parse();
    match args.command {
        Commands::Run(run) => match run.command {
            RunCommands::Dev => println!("run dev has been called"),
        },
    }
}
