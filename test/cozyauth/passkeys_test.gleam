import gleeunit
import gleeunit/should
import cozyauth/passkeys

pub fn main() {
  gleeunit.main()
}

pub fn add_test() {
  passkeys.add(1, 2)
  |> should.equal(3)
}
