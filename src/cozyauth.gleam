import gleam/erlang/process
import gleam/string_builder
import mist
import wisp.{type Request, type Response}

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    wisp.mist_handler(
      fn(_req: Request) -> Response {
        let body = string_builder.from_string("<h1>hallo, Mateo!</h1>")
        wisp.html_response(body, 200)
      },
      secret_key_base,
    )
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http
  process.sleep_forever()
}
