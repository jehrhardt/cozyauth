use askama::Template;
use axum::{extract::State, response::Redirect, Form};
use serde::Deserialize;

use crate::app;

#[derive(Template)]
#[template(path = "sign-in.html")]
pub(crate) struct SignInPageTemplate {
    errors: Option<Errors>,
}

struct Errors {
    email: String,
}

#[derive(Deserialize)]
pub(crate) struct FormData {
    email: String,
}

pub(crate) async fn render_page() -> SignInPageTemplate {
    SignInPageTemplate { errors: None }
}

pub(crate) async fn handle_form_submission(
    State(_context): State<app::Context>,
    Form(form_data): Form<FormData>,
) -> Result<Redirect, SignInPageTemplate> {
    let email = form_data.email;
    let errors = if email.is_empty() {
        Some(Errors {
            email: "Email is required".to_string(),
        })
    } else {
        None
    };
    if errors.is_some() {
        Err(SignInPageTemplate { errors })
    } else {
        Ok(Redirect::to("/"))
    }
}
