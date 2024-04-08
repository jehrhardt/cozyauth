use pavex::response::Response;

pub fn get() -> Response {
    Response::ok().set_typed_body("OK")
}
