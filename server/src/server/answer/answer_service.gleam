import gleam/result
import gleamrpc
import server/answer/sql
import server/context
import server/db_utils
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
    sql.create_answer(db, id, params.question_id, params.answer, params.correct)
    |> result.then(fn(_) { sql.get_answer(db, id) })
  }
  |> result.then(db_utils.get_one)
  |> result.map(fn(v: sql.GetAnswerRow) {
    answer.Answer(
      id: v.id,
      question_id: v.question_id,
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
    sql.update_answer(db, params.answer, params.correct, params.id)
    |> result.then(fn(_) { sql.get_answer(db, params.id) })
  }
  |> result.then(db_utils.get_one)
  |> result.map(fn(v: sql.GetAnswerRow) {
    answer.Answer(
      id: v.id,
      question_id: v.question_id,
      answer: v.answer,
      correct: v.correct,
    )
  })
}

fn delete(
  params: uuid.Uuid,
  context: context.Context,
) -> Result(Nil, gleamrpc.ProcedureError) {
  {
    use db <- db_utils.transaction(context)
    sql.delete_answer(db, params)
  }
  |> result.replace(Nil)
}
