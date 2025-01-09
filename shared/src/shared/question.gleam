import convert
import gleam/option
import gleamrpc
import shared
import shared/answer

pub type Question {
  Question(id: shared.Uuid, qwiz_id: shared.Uuid, question: String)
}

pub type QuestionWithAnswers {
  QuestionWithAnswers(
    id: shared.Uuid,
    qwiz_id: shared.Uuid,
    question: String,
    answers: List(answer.Answer),
  )
}

pub type CreateQuestion {
  CreateQuestion(qwiz_id: shared.Uuid, question: String)
}

pub fn question_converter() -> convert.Converter(Question) {
  convert.object({
    use id <- convert.field(
      "id",
      fn(v: Question) { Ok(v.id) },
      shared.uuid_converter(),
    )
    use qwiz_id <- convert.field(
      "qwiz_id",
      fn(v: Question) { Ok(v.qwiz_id) },
      shared.uuid_converter(),
    )
    use question <- convert.field(
      "question",
      fn(v: Question) { Ok(v.question) },
      convert.string(),
    )

    convert.success(Question(id:, qwiz_id:, question:))
  })
}

pub fn question_with_answers_converter() -> convert.Converter(
  QuestionWithAnswers,
) {
  convert.object({
    use id <- convert.field(
      "id",
      fn(v: QuestionWithAnswers) { Ok(v.id) },
      shared.uuid_converter(),
    )
    use qwiz_id <- convert.field(
      "qwiz_id",
      fn(v: QuestionWithAnswers) { Ok(v.qwiz_id) },
      shared.uuid_converter(),
    )
    use question <- convert.field(
      "question",
      fn(v: QuestionWithAnswers) { Ok(v.question) },
      convert.string(),
    )
    use answers <- convert.field(
      "answers",
      fn(v: QuestionWithAnswers) { Ok(v.answers) },
      convert.list(answer.answer_converter()),
    )

    convert.success(QuestionWithAnswers(id:, qwiz_id:, question:, answers:))
  })
}

pub fn create_question_converter() -> convert.Converter(CreateQuestion) {
  convert.object({
    use qwiz_id <- convert.field(
      "qwiz_id",
      fn(v: CreateQuestion) { Ok(v.qwiz_id) },
      shared.uuid_converter(),
    )
    use question <- convert.field(
      "question",
      fn(v: CreateQuestion) { Ok(v.question) },
      convert.string(),
    )
    convert.success(CreateQuestion(qwiz_id:, question:))
  })
}

pub fn get_question() -> gleamrpc.Procedure(shared.Uuid, QuestionWithAnswers) {
  gleamrpc.query("get_question", option.None)
  |> gleamrpc.params(shared.uuid_converter())
  |> gleamrpc.returns(question_with_answers_converter())
}

pub fn create_question() -> gleamrpc.Procedure(
  CreateQuestion,
  QuestionWithAnswers,
) {
  gleamrpc.mutation("create_question", option.None)
  |> gleamrpc.params(create_question_converter())
  |> gleamrpc.returns(question_with_answers_converter())
}

pub fn update_question() -> gleamrpc.Procedure(Question, QuestionWithAnswers) {
  gleamrpc.mutation("update_question", option.None)
  |> gleamrpc.params(question_converter())
  |> gleamrpc.returns(question_with_answers_converter())
}

pub fn delete_question() -> gleamrpc.Procedure(shared.Uuid, Nil) {
  gleamrpc.mutation("delete_question", option.None)
  |> gleamrpc.params(shared.uuid_converter())
  |> gleamrpc.returns(convert.null())
}
