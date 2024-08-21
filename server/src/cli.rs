// Copyright 2024 Cozy Auth Contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

use clap::{Parser, Subcommand};

use crate::{app::start_server, config::Settings, db::migrate};

#[derive(Debug, Parser)]
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
        Commands::Migrate => migrate(&settings).await,
    }
}
