import convert
import gleam/dynamic
import gleam/regexp

/// We have to use our own Uuid because youid isn't compatible with the browser
pub type Uuid {
  Uuid(data: String)
}

pub fn uuid_converter() -> convert.Converter(Uuid) {
  convert.string()
  |> convert.map(
    fn(uuid: Uuid) { uuid.data },
    fn(v: String) {
      let assert Ok(re) =
        regexp.from_string(
          "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
        )
        as "UUID regex should be valid !"

      case re |> regexp.check(v) {
        False -> Error([dynamic.DecodeError("A valid UUID", v, [])])
        True -> Ok(Uuid(v))
      }
    },
    Uuid("00000000-0000-0000-0000-000000000000"),
  )
}
