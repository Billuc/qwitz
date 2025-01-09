import gleam/list
import gleam/result
import gleamrpc
import server/answer/sql as answer_sql
import server/context
import server/db_utils
import server/question/sql
import shared/answer
import shared/question
import youid/uuid

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  server
  |> gleamrpc.with_implementation(question.get_question(), get)
  |> gleamrpc.with_implementation(question.create_question(), create)
  |> gleamrpc.with_implementation(question.update_question(), update)
  |> gleamrpc.with_implementation(question.delete_question(), delete)
}

fn get(
  params: uuid.Uuid,
  context: context.Context,
) -> Result(question.QuestionWithAnswers, gleamrpc.ProcedureError) {
  sql.get_question(context.db, params)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.then(db_utils.get_one)
  |> result.then(fn(v: sql.GetQuestionRow) {
    answer_sql.get_all_answers(context.db, v.id)
    |> result.map_error(db_utils.query_error_to_procedure_error)
    |> result.map(fn(res) {
      use row <- list.map(res.rows)
      answer.Answer(row.id, row.question_id, row.answer, row.correct)
    })
    |> result.map(question.QuestionWithAnswers(
      id: v.id,
      question: v.question,
      qwiz_id: v.qwiz_id,
      answers: _,
    ))
  })
}

fn create(
  params: question.CreateQuestion,
  context: context.Context,
) -> Result(question.QuestionWithAnswers, gleamrpc.ProcedureError) {
  let id = uuid.v4()

  sql.create_question(context.db, id, params.qwiz_id, params.question)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.then(fn(_) { get(id, context) })
}

fn update(
  params: question.Question,
  context: context.Context,
) -> Result(question.QuestionWithAnswers, gleamrpc.ProcedureError) {
  sql.update_question(context.db, params.question, params.id)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.then(fn(_) { get(params.id, context) })
}

fn delete(
  params: uuid.Uuid,
  context: context.Context,
) -> Result(Nil, gleamrpc.ProcedureError) {
  sql.delete_question(context.db, params)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.replace(Nil)
}
