import convert
import gleam/option
import gleamrpc
import shared
import shared/question
import youid/uuid

pub type Qwiz {
  Qwiz(id: uuid.Uuid, name: String, owner: uuid.Uuid)
}

pub type QwizWithQuestions {
  QwizWithQuestions(
    id: uuid.Uuid,
    name: String,
    owner: uuid.Uuid,
    questions: List(question.Question),
  )
}

pub type UpsertQwiz {
  UpsertQwiz(name: String, owner: uuid.Uuid)
}

pub fn qwiz_converter() -> convert.Converter(Qwiz) {
  convert.object({
    use id <- convert.field(
      "id",
      fn(v: Qwiz) { Ok(v.id) },
      shared.uuid_converter(),
    )
    use name <- convert.field(
      "name",
      fn(v: Qwiz) { Ok(v.name) },
      convert.string(),
    )
    use owner <- convert.field(
      "owner",
      fn(v: Qwiz) { Ok(v.owner) },
      shared.uuid_converter(),
    )

    convert.success(Qwiz(id:, name:, owner:))
  })
}

pub fn qwiz_with_questions_converter() -> convert.Converter(QwizWithQuestions) {
  convert.object({
    use id <- convert.field(
      "id",
      fn(v: QwizWithQuestions) { Ok(v.id) },
      shared.uuid_converter(),
    )
    use name <- convert.field(
      "name",
      fn(v: QwizWithQuestions) { Ok(v.name) },
      convert.string(),
    )
    use owner <- convert.field(
      "owner",
      fn(v: QwizWithQuestions) { Ok(v.owner) },
      shared.uuid_converter(),
    )
    use questions <- convert.field(
      "questions",
      fn(v: QwizWithQuestions) { Ok(v.questions) },
      convert.list(question.question_converter()),
    )

    convert.success(QwizWithQuestions(id:, name:, owner:, questions:))
  })
}

pub fn upsert_qwiz_converter() -> convert.Converter(UpsertQwiz) {
  convert.object({
    use name <- convert.field(
      "name",
      fn(v: UpsertQwiz) { Ok(v.name) },
      convert.string(),
    )
    use owner <- convert.field(
      "owner",
      fn(v: UpsertQwiz) { Ok(v.owner) },
      shared.uuid_converter(),
    )

    convert.success(UpsertQwiz(name:, owner:))
  })
}

pub fn get_qwizes() -> gleamrpc.Procedure(Nil, List(Qwiz)) {
  gleamrpc.query("get_qwizes", option.None)
  |> gleamrpc.params(convert.null())
  |> gleamrpc.returns(convert.list(qwiz_converter()))
}

pub fn get_qwiz() -> gleamrpc.Procedure(uuid.Uuid, QwizWithQuestions) {
  gleamrpc.query("get_qwiz", option.None)
  |> gleamrpc.params(shared.uuid_converter())
  |> gleamrpc.returns(qwiz_with_questions_converter())
}

pub fn create_qwiz() -> gleamrpc.Procedure(UpsertQwiz, QwizWithQuestions) {
  gleamrpc.mutation("create_qwiz", option.None)
  |> gleamrpc.params(upsert_qwiz_converter())
  |> gleamrpc.returns(qwiz_with_questions_converter())
}

pub fn update_qwiz() -> gleamrpc.Procedure(Qwiz, QwizWithQuestions) {
  gleamrpc.mutation("update_qwiz", option.None)
  |> gleamrpc.params(qwiz_converter())
  |> gleamrpc.returns(qwiz_with_questions_converter())
}

pub fn delete_qwiz() -> gleamrpc.Procedure(uuid.Uuid, Nil) {
  gleamrpc.mutation("delete_qwiz", option.None)
  |> gleamrpc.params(shared.uuid_converter())
  |> gleamrpc.returns(convert.null())
}
