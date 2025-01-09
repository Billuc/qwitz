import gleam/result
import gleamrpc
import server/answer/sql
import server/context
import server/db_utils
import shared
import shared/answer
import youid/uuid

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  server
  |> gleamrpc.with_implementation(answer.create_answer(), create)
  |> gleamrpc.with_implementation(answer.update_answer(), update)
  |> gleamrpc.with_implementation(answer.delete_answer(), delete)
}

fn create(
  params: answer.CreateAnswer,
  context: context.Context,
) -> Result(answer.Answer, gleamrpc.ProcedureError) {
  let id = uuid.v4()

  {
    use db <- db_utils.transaction(context)
    sql.create_answer(
      db,
      id,
      db_utils.shared_to_youid(params.question_id),
      params.answer,
      params.correct,
    )
    |> result.then(fn(_) { sql.get_answer(db, id) })
  }
  |> result.then(db_utils.get_one)
  |> result.map(fn(v: sql.GetAnswerRow) {
    answer.Answer(
      id: db_utils.youid_to_shared(v.id),
      question_id: db_utils.youid_to_shared(v.question_id),
      answer: v.answer,
      correct: v.correct,
    )
  })
}

fn update(
  params: answer.Answer,
  context: context.Context,
) -> Result(answer.Answer, gleamrpc.ProcedureError) {
  {
    use db <- db_utils.transaction(context)
    sql.update_answer(
      db,
      params.answer,
      params.correct,
      db_utils.shared_to_youid(params.id),
    )
    |> result.then(fn(_) {
      sql.get_answer(db, db_utils.shared_to_youid(params.id))
    })
  }
  |> result.then(db_utils.get_one)
  |> result.map(fn(v: sql.GetAnswerRow) {
    answer.Answer(
      id: db_utils.youid_to_shared(v.id),
      question_id: db_utils.youid_to_shared(v.question_id),
      answer: v.answer,
      correct: v.correct,
    )
  })
}

fn delete(
  params: shared.Uuid,
  context: context.Context,
) -> Result(Nil, gleamrpc.ProcedureError) {
  sql.delete_answer(context.db, db_utils.shared_to_youid(params))
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.replace(Nil)
}
