// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: GPL-3.0-or-later

use clap::Subcommand;

#[derive(Subcommand)]
pub(crate) enum Commands {
    Login,
}

pub(crate) fn run(command: Commands) {
    match command {
        Commands::Login => print!("Please login with your Supabase account"),
    }
}
