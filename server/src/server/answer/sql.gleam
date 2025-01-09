import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// Runs the `create_answer` query
/// defined in `./src/server/answer/sql/create_answer.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_answer(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "INSERT INTO answers(id, question_id, answer, correct) 
VALUES ($1, $2, $3, $4);"

  pog.query(query)
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.bool(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_answer` query
/// defined in `./src/server/answer/sql/delete_answer.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_answer(db, arg_1) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "DELETE FROM answers
WHERE id = $1;"

  pog.query(query)
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_all_answers` query
/// defined in `./src/server/answer/sql/get_all_answers.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.1.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetAllAnswersRow {
  GetAllAnswersRow(id: Uuid, question_id: Uuid, answer: String, correct: Bool)
}

/// Runs the `get_all_answers` query
/// defined in `./src/server/answer/sql/get_all_answers.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_all_answers(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use question_id <- decode.field(1, uuid_decoder())
    use answer <- decode.field(2, decode.string)
    use correct <- decode.field(3, decode.bool)
    decode.success(GetAllAnswersRow(id:, question_id:, answer:, correct:))
  }

  let query = "SELECT id, question_id, answer, correct
FROM answers
WHERE question_id = $1;"

  pog.query(query)
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_answer` query
/// defined in `./src/server/answer/sql/update_answer.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_answer(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "UPDATE answers
SET 
    answer = $1,
    correct = $2
WHERE id = $3;"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.bool(arg_2))
  |> pog.parameter(pog.text(uuid.to_string(arg_3)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_answer` query
/// defined in `./src/server/answer/sql/get_answer.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.1.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetAnswerRow {
  GetAnswerRow(id: Uuid, question_id: Uuid, answer: String, correct: Bool)
}

/// Runs the `get_answer` query
/// defined in `./src/server/answer/sql/get_answer.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_answer(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use question_id <- decode.field(1, uuid_decoder())
    use answer <- decode.field(2, decode.string)
    use correct <- decode.field(3, decode.bool)
    decode.success(GetAnswerRow(id:, question_id:, answer:, correct:))
  }

  let query = "SELECT id, question_id, answer, correct
FROM answers
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
