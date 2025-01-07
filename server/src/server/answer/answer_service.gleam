import gleam/list
import gleam/result
import server/answer/sql
import server/context
import server/db_utils
import shared/answer
import youid/uuid

import gleamrpc

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  server
  |> gleamrpc.with_implementation(answer.get_answer(), get)
  |> gleamrpc.with_implementation(answer.get_answers(), get_all)
  |> gleamrpc.with_implementation(answer.create_answer(), create)
  |> gleamrpc.with_implementation(answer.update_answer(), update)
  |> gleamrpc.with_implementation(answer.delete_answer(), delete)
}

fn get(
  params: uuid.Uuid,
  context: context.Context,
) -> Result(answer.Answer, gleamrpc.ProcedureError) {
  {
    use db <- db_utils.transaction(context)
    sql.get_answer(db, params)
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

fn get_all(
  _params: Nil,
  context: context.Context,
) -> Result(List(answer.Answer), gleamrpc.ProcedureError) {
  {
    use db <- db_utils.transaction(context)
    sql.get_all_answers(db)
  }
  |> result.map(db_utils.get_all)
  |> result.map(fn(v: List(sql.GetAllAnswersRow)) {
    use answer_row <- list.map(v)
    answer.Answer(
      id: answer_row.id,
      question_id: answer_row.question_id,
      answer: answer_row.answer,
      correct: answer_row.correct,
    )
  })
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
