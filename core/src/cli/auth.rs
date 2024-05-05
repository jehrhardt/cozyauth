// © Copyright 2024 the cozyauth developers
// SPDX-License-Identifier: GPL-3.0-or-later

use std::time::Duration;

use clap::Subcommand;
use color_eyre::eyre::Ok;
use crossterm::event::{self, Event, KeyCode, KeyEvent, KeyModifiers};
use ratatui::{
    style::Stylize,
    text::{Line, Text},
    widgets::Paragraph,
    Frame,
};

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
    email: Option<String>,
}

#[derive(Debug, Default, PartialEq, Eq)]
enum Status {
    #[default]
    Running,
    Done,
}

#[derive(Debug, PartialEq)]
enum Message {
    Next,
    Quit,
}
fn launch_tui() -> color_eyre::Result<()> {
    tui::install_panic_hook();
    let mut terminal = tui::init_terminal()?;
    let mut model = Model::default();

    while model.status != Status::Done {
        terminal.draw(|f| view(&mut model, f))?;
        let mut current_msg = handle_event()?;

        while current_msg.is_some() {
            current_msg = update(&mut model, current_msg.unwrap());
        }
    }

    tui::restore_terminal()?;
    Ok(())
}

fn view(model: &mut Model, f: &mut Frame) {
    f.render_widget(
        Paragraph::new(Text::from(vec![Line::from(vec![
            "?".green(),
            " What is your email address? ".into(),
            "> ".dark_gray(),
            model
                .email
                .as_ref()
                .map_or_else(|| "me@example.com".to_string(), |e| e.to_string())
                .dark_gray(),
        ])])),
        f.size(),
    );
}

fn handle_event() -> color_eyre::Result<Option<Message>> {
    if event::poll(Duration::from_millis(16))? {
        if let Event::Key(key) = event::read()? {
            return handle_key_event(key);
        }
    }
    Ok(None)
}

fn handle_key_event(key: KeyEvent) -> color_eyre::Result<Option<Message>> {
    match key {
        KeyEvent {
            code: KeyCode::Char('c'),
            modifiers: KeyModifiers::CONTROL,
            ..
        } => Ok(Some(Message::Quit)),
        KeyEvent {
            code: KeyCode::Enter,
            ..
        } => Ok(Some(Message::Next)),
        _ => Ok(None),
    }
}

fn update(model: &mut Model, message: Message) -> Option<Message> {
    match message {
        Message::Quit => model.status = Status::Done,
        Message::Next => model.status = Status::Done,
    }
    None
}

#[cfg(test)]
mod tests {
    use crossterm::event::{KeyEventKind, KeyEventState};
    use ratatui::{
        backend::TestBackend,
        buffer::Buffer,
        layout::Rect,
        style::{Style, Stylize},
        Terminal,
    };

    use super::*;

    #[test]
    fn initial_screen() {
        let mut terminal = Terminal::new(TestBackend::new(46, 4)).unwrap();
        let mut model = Model::default();
        terminal.draw(|f| view(&mut model, f)).unwrap();
        let mut expected = Buffer::with_lines(vec![
            "? What is your email address? > me@example.com",
            "",
            "",
            "",
        ]);
        let highlight_style = Style::new().green();
        let suggestion_style = Style::new().dark_gray();
        expected.set_style(Rect::new(0, 0, 1, 1), highlight_style);
        expected.set_style(Rect::new(30, 0, 16, 1), suggestion_style);
        terminal.backend().assert_buffer(&expected);
    }

    #[test]
    fn handle_ctrl_c_key() {
        let key = KeyEvent {
            code: KeyCode::Char('c'),
            modifiers: KeyModifiers::CONTROL,
            kind: KeyEventKind::Press,
            state: KeyEventState::empty(),
        };
        assert_eq!(Some(Message::Quit), handle_key_event(key).unwrap());
    }

    #[test]
    fn handle_enter_key() {
        let key = KeyEvent {
            code: KeyCode::Enter,
            modifiers: KeyModifiers::NONE,
            kind: KeyEventKind::Press,
            state: KeyEventState::empty(),
        };
        assert_eq!(Some(Message::Next), handle_key_event(key).unwrap());
    }
}
