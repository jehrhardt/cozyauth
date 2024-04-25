import gleam/json
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  case wisp.path_segments(req) {
    ["health"] -> health()
    _ -> wisp.not_found()
  }
}

fn health() {
  let status = json.object([#("status", json.string("✅"))])
  let body = json.to_string_builder(status)
  wisp.json_response(body, 200)
}
