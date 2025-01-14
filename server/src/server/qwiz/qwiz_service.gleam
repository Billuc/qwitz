import gleam/result
import gleamrpc
import server/context
import server/db_utils
import server/log
import server/question/question_repository
import server/qwiz/qwiz_repository
import shared
import shared/qwiz

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  log.log("Registering qwiz procedures")

  server
  |> gleamrpc.with_implementation(qwiz.get_qwiz(), get)
  |> gleamrpc.with_implementation(qwiz.get_qwizes(), get_all)
  |> gleamrpc.with_implementation(qwiz.create_qwiz(), create)
  |> gleamrpc.with_implementation(qwiz.update_qwiz(), update)
  |> gleamrpc.with_implementation(qwiz.delete_qwiz(), delete)
}

fn get_with_questions(
  params: shared.Uuid,
  context: context.Context,
) -> Result(qwiz.QwizWithQuestions, db_utils.DatabaseError) {
  qwiz_repository.get(params, context)
  |> result.then(fn(qwiz) {
    question_repository.get_by_qwiz_id(qwiz.id, context)
    |> result.map(qwiz.QwizWithQuestions(
      id: qwiz.id,
      name: qwiz.name,
      owner: qwiz.owner,
      questions: _,
    ))
  })
}

fn get(
  params: shared.Uuid,
  context: context.Context,
) -> Result(qwiz.QwizWithQuestions, gleamrpc.ProcedureError) {
  use <- log.time_log_in_out("[qwiz] service get", params.data)

  get_with_questions(params, context)
  |> result.map_error(db_utils.database_to_procedure_error)
}

fn get_all(
  _params: Nil,
  context: context.Context,
) -> Result(List(qwiz.Qwiz), gleamrpc.ProcedureError) {
  use <- log.time_log_in_out("[qwiz] service get_all", Nil)

  qwiz_repository.get_all(context)
  |> result.map_error(db_utils.database_to_procedure_error)
}

fn create(
  params: qwiz.UpsertQwiz,
  context: context.Context,
) -> Result(qwiz.QwizWithQuestions, gleamrpc.ProcedureError) {
  use <- log.time_log_in_out("[qwiz] service create", params)

  qwiz_repository.create(params, context)
  |> result.then(get_with_questions(_, context))
  |> result.map_error(db_utils.database_to_procedure_error)
}

fn update(
  params: qwiz.Qwiz,
  context: context.Context,
) -> Result(qwiz.QwizWithQuestions, gleamrpc.ProcedureError) {
  use <- log.time_log_in_out("[qwiz] service update", params)

  qwiz_repository.update(params, context)
  |> result.then(get_with_questions(_, context))
  |> result.map_error(db_utils.database_to_procedure_error)
}

fn delete(
  params: shared.Uuid,
  context: context.Context,
) -> Result(Nil, gleamrpc.ProcedureError) {
  use <- log.time_log_in_out("[qwiz] service delete", params.data)

  qwiz_repository.delete(params, context)
  |> result.map_error(db_utils.database_to_procedure_error)
}
