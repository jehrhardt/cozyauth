// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: GPL-3.0-or-later

use clap::{Parser, Subcommand};

mod auth;
mod tui;

#[derive(Parser)]
#[command(name = "cozyauth", version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    Auth {
        #[command(subcommand)]
        command: auth::Commands,
    },
}

pub fn run() -> color_eyre::Result<()> {
    let cli = Cli::parse();

    if let Some(cmd) = cli.command {
        match cmd {
            Commands::Auth { command } => auth::run(command),
        }
    } else {
        Ok(())
    }
}
