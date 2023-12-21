use askama::Template;
use askama_axum::IntoResponse;

#[derive(Template)]
#[template(path = "sign-in.html")]
pub(crate) struct SignInPageTemplate {
    errors: Option<Errors>,
}

struct Errors {
    email: String,
}

pub(crate) async fn render_page() -> impl IntoResponse {
    SignInPageTemplate {
        errors: None,
    }
}
