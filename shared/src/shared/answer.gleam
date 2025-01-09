import convert
import gleam/option
import gleamrpc
import shared

pub type Answer {
  Answer(
    id: shared.Uuid,
    question_id: shared.Uuid,
    answer: String,
    correct: Bool,
  )
}

pub type CreateAnswer {
  CreateAnswer(question_id: shared.Uuid, answer: String, correct: Bool)
}

pub fn answer_converter() -> convert.Converter(Answer) {
  convert.object({
    use id <- convert.field(
      "id",
      fn(v: Answer) { Ok(v.id) },
      shared.uuid_converter(),
    )
    use question_id <- convert.field(
      "question_id",
      fn(v: Answer) { Ok(v.question_id) },
      shared.uuid_converter(),
    )
    use answer <- convert.field(
      "answer",
      fn(v: Answer) { Ok(v.answer) },
      convert.string(),
    )
    use correct <- convert.field(
      "correct",
      fn(v: Answer) { Ok(v.correct) },
      convert.bool(),
    )

    convert.success(Answer(id:, question_id:, answer:, correct:))
  })
}

pub fn create_answer_converter() -> convert.Converter(CreateAnswer) {
  convert.object({
    use question_id <- convert.field(
      "question_id",
      fn(v: CreateAnswer) { Ok(v.question_id) },
      shared.uuid_converter(),
    )
    use answer <- convert.field(
      "answer",
      fn(v: CreateAnswer) { Ok(v.answer) },
      convert.string(),
    )
    use correct <- convert.field(
      "correct",
      fn(v: CreateAnswer) { Ok(v.correct) },
      convert.bool(),
    )

    convert.success(CreateAnswer(question_id:, answer:, correct:))
  })
}

pub fn create_answer() -> gleamrpc.Procedure(CreateAnswer, Answer) {
  gleamrpc.mutation("create_answer", option.None)
  |> gleamrpc.params(create_answer_converter())
  |> gleamrpc.returns(answer_converter())
}

pub fn update_answer() -> gleamrpc.Procedure(Answer, Answer) {
  gleamrpc.mutation("update_answer", option.None)
  |> gleamrpc.params(answer_converter())
  |> gleamrpc.returns(answer_converter())
}

pub fn delete_answer() -> gleamrpc.Procedure(shared.Uuid, Nil) {
  gleamrpc.mutation("delete_answer", option.None)
  |> gleamrpc.params(shared.uuid_converter())
  |> gleamrpc.returns(convert.null())
}
