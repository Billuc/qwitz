import gleam/dynamic/decode
import gleam/option.{type Option}
import pog
import youid/uuid.{type Uuid}

/// Runs the `create_question` query
/// defined in `./src/server/question/sql/create_question.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_question(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "INSERT INTO questions(id, qwiz_id, question)
VALUES ($1, $2, $3);"

  pog.query(query)
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.text(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_question` query
/// defined in `./src/server/question/sql/update_question.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_question(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "UPDATE questions
SET question = $1
WHERE id = $2;"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_question` query
/// defined in `./src/server/question/sql/delete_question.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_question(db, arg_1) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "DELETE FROM questions
WHERE id = $1;"

  pog.query(query)
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_all_questions` query
/// defined in `./src/server/question/sql/get_all_questions.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.1.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetAllQuestionsRow {
  GetAllQuestionsRow(
    question_id: Uuid,
    qwiz_id: Uuid,
    question: String,
    answer_id: Option(Uuid),
    answer: Option(String),
    correct: Option(Bool),
  )
}

/// Runs the `get_all_questions` query
/// defined in `./src/server/question/sql/get_all_questions.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_all_questions(db, arg_1) {
  let decoder = {
    use question_id <- decode.field(0, uuid_decoder())
    use qwiz_id <- decode.field(1, uuid_decoder())
    use question <- decode.field(2, decode.string)
    use answer_id <- decode.field(3, decode.optional(uuid_decoder()))
    use answer <- decode.field(4, decode.optional(decode.string))
    use correct <- decode.field(5, decode.optional(decode.bool))
    decode.success(
      GetAllQuestionsRow(
        question_id:,
        qwiz_id:,
        question:,
        answer_id:,
        answer:,
        correct:,
      ),
    )
  }

  let query = "SELECT 
  q.id AS question_id, 
  q.qwiz_id, 
  q.question, 
  a.id AS answer_id, 
  a.answer, 
  a.correct 
FROM 
  questions q
LEFT JOIN 
  answers a 
ON 
  q.id = a.question_id
WHERE
  q.qwiz_id = $1;"

  pog.query(query)
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_question` query
/// defined in `./src/server/question/sql/get_question.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.1.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetQuestionRow {
  GetQuestionRow(
    question_id: Uuid,
    qwiz_id: Uuid,
    question: String,
    answer_id: Option(Uuid),
    answer: Option(String),
    correct: Option(Bool),
  )
}

/// Runs the `get_question` query
/// defined in `./src/server/question/sql/get_question.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_question(db, arg_1) {
  let decoder = {
    use question_id <- decode.field(0, uuid_decoder())
    use qwiz_id <- decode.field(1, uuid_decoder())
    use question <- decode.field(2, decode.string)
    use answer_id <- decode.field(3, decode.optional(uuid_decoder()))
    use answer <- decode.field(4, decode.optional(decode.string))
    use correct <- decode.field(5, decode.optional(decode.bool))
    decode.success(
      GetQuestionRow(
        question_id:,
        qwiz_id:,
        question:,
        answer_id:,
        answer:,
        correct:,
      ),
    )
  }

  let query = "SELECT 
  q.id AS question_id, 
  q.qwiz_id, 
  q.question, 
  a.id AS answer_id, 
  a.answer, 
  a.correct 
FROM 
  questions q
LEFT JOIN 
  answers a 
ON 
  q.id = a.question_id
WHERE 
  q.id = $1;"

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
