import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `get_qwiz` query
/// defined in `./src/server/qwiz/sql/get_qwiz.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.1.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetQwizRow {
  GetQwizRow(id: Uuid, name: String, owner: Uuid)
}

/// Runs the `get_qwiz` query
/// defined in `./src/server/qwiz/sql/get_qwiz.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_qwiz(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use name <- decode.field(1, decode.string)
    use owner <- decode.field(2, uuid_decoder())
    decode.success(GetQwizRow(id:, name:, owner:))
  }

  let query = "SELECT *
FROM qwizes
WHERE id = $1;"

  pog.query(query)
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Encoding/decoding utils -------------------------------------------------

/// A decoder to decode `Uuid`s coming from a Postgres query.
///
fn uuid_decoder() {
  use bit_array <- decode.then(decode.bit_array)
  case uuid.from_bit_array(bit_array) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> decode.failure(uuid.v7(), "uuid")
  }
}
