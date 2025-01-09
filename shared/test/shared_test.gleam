import convert
import gleam/dynamic
import gleeunit
import gleeunit/should
import shared

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn uuid_converter_test() {
  convert.StringValue("f4eb61c5-409b-4d5c-b392-b0a0065dda62")
  |> convert.decode(shared.uuid_converter())
  |> should.be_ok
  |> should.equal(shared.Uuid("f4eb61c5-409b-4d5c-b392-b0a0065dda62"))
}

pub fn uuid_converter_fail_test() {
  convert.StringValue("I am not a UUID")
  |> convert.decode(shared.uuid_converter())
  |> should.be_error
  |> should.equal([dynamic.DecodeError("A valid UUID", "I am not a UUID", [])])
}
