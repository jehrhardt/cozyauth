import gleam/json
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  case wisp.path_segments(req) {
    ["health"] -> health()
    _ -> wisp.not_found()
  }
}

fn health() {
  [#("status", json.string("✅"))]
  |> json.object()
  |> json.to_string_builder()
  |> wisp.json_response(200)
}
