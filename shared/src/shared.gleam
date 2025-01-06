import convert
import gleam/bit_array
import gleam/dynamic
import gleam/result
import youid/uuid

pub fn uuid_converter() -> convert.Converter(uuid.Uuid) {
  convert.bit_array()
  |> convert.map(
    uuid.to_bit_array,
    fn(v) {
      uuid.from_bit_array(v)
      |> result.replace_error([
        dynamic.DecodeError(
          "A valid UUID",
          bit_array.base64_encode(v, True),
          [],
        ),
      ])
    },
    uuid.v4(),
  )
}
