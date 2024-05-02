// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: GPL-3.0-or-later

use std::time::Duration;

use clap::Subcommand;
use crossterm::event::{self, Event, KeyCode};
use ratatui::{widgets::Paragraph, Frame};

use super::tui;

#[derive(Subcommand)]
pub(crate) enum Commands {
    Login,
}

pub(crate) fn run(command: Commands) -> color_eyre::Result<()> {
    match command {
        Commands::Login => launch_tui(),
    }
}

#[derive(Default)]
struct Model {
    status: Status,
}

#[derive(Debug, Default, PartialEq, Eq)]
enum Status {
    #[default]
    Running,
    Done,
}

enum Message {
    Quit,
}
fn launch_tui() -> color_eyre::Result<()> {
    tui::install_panic_hook();
    let mut terminal = tui::init_terminal()?;
    let mut model = Model::default();

    while model.status != Status::Done {
        terminal.draw(|f| view(&mut model, f))?;
        let mut current_msg = handle_event()?;

        // Process updates as long as they return a non-None message
        while current_msg.is_some() {
            current_msg = update(&mut model, current_msg.unwrap());
        }
    }

    tui::restore_terminal()?;
    Ok(())
}

fn view(_model: &mut Model, f: &mut Frame) {
    f.render_widget(Paragraph::new("Press `q` to quit"), f.size());
}

fn handle_event() -> color_eyre::Result<Option<Message>> {
    if event::poll(Duration::from_millis(250))? {
        if let Event::Key(key) = event::read()? {
            if key.kind == event::KeyEventKind::Press {
                return match key.code {
                    KeyCode::Char('q') => Ok(Some(Message::Quit)),
                    _ => Ok(None),
                };
            }
        }
    }
    Ok(None)
}

fn update(model: &mut Model, message: Message) -> Option<Message> {
    match message {
        Message::Quit => model.status = Status::Done,
    }
    None
}
