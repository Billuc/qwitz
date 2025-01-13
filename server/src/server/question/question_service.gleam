import gleam/result
import gleamrpc
import server/answer/answer_repository
import server/context
import server/db_utils
import server/question/question_repository
import shared
import shared/question

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  server
  |> gleamrpc.with_implementation(question.get_question(), get)
  |> gleamrpc.with_implementation(question.create_question(), create)
  |> gleamrpc.with_implementation(question.update_question(), update)
  |> gleamrpc.with_implementation(question.delete_question(), delete)
}

fn get_with_answers(
  params: shared.Uuid,
  context: context.Context,
) -> Result(question.QuestionWithAnswers, db_utils.DatabaseError) {
  question_repository.get(params, context)
  |> result.then(fn(q) {
    answer_repository.get_by_question_id(q.id, context)
    |> result.map(question.QuestionWithAnswers(
      id: q.id,
      question: q.question,
      qwiz_id: q.qwiz_id,
      answers: _,
    ))
  })
}

fn get(
  params: shared.Uuid,
  context: context.Context,
) -> Result(question.QuestionWithAnswers, gleamrpc.ProcedureError) {
  get_with_answers(params, context)
  |> result.map_error(db_utils.database_to_procedure_error)
}

fn create(
  params: question.CreateQuestion,
  context: context.Context,
) -> Result(question.QuestionWithAnswers, gleamrpc.ProcedureError) {
  question_repository.create(params, context)
  |> result.then(get_with_answers(_, context))
  |> result.map_error(db_utils.database_to_procedure_error)
}

fn update(
  params: question.Question,
  context: context.Context,
) -> Result(question.QuestionWithAnswers, gleamrpc.ProcedureError) {
  question_repository.update(params, context)
  |> result.then(get_with_answers(_, context))
  |> result.map_error(db_utils.database_to_procedure_error)
}

fn delete(
  params: shared.Uuid,
  context: context.Context,
) -> Result(Nil, gleamrpc.ProcedureError) {
  question_repository.delete(params, context)
  |> result.map_error(db_utils.database_to_procedure_error)
}
