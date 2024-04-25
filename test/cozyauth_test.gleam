import cozyauth/router
import gleeunit
import gleeunit/should
import wisp/testing

pub fn main() {
  gleeunit.main()
}

pub fn health_test() {
  let response =
    testing.get("/health", [])
    |> router.handle_request()

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "application/json")])

  response
  |> testing.string_body
  |> should.equal("{\"status\":\"✅\"}")
}

pub fn not_found_test() {
  let response =
    testing.get("/foo/bar", [])
    |> router.handle_request()

  response.status
  |> should.equal(404)
}
