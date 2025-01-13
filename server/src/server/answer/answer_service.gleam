import gleam/result
import gleamrpc
import server/answer/answer_repository
import server/context
import server/db_utils
import shared
import shared/answer

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
  answer_repository.create(params, context)
  |> result.then(answer_repository.get(_, context))
  |> result.map_error(db_utils.database_to_procedure_error)
}

fn update(
  params: answer.Answer,
  context: context.Context,
) -> Result(answer.Answer, gleamrpc.ProcedureError) {
  answer_repository.update(params, context)
  |> result.then(answer_repository.get(_, context))
  |> result.map_error(db_utils.database_to_procedure_error)
}

fn delete(
  params: shared.Uuid,
  context: context.Context,
) -> Result(Nil, gleamrpc.ProcedureError) {
  answer_repository.delete(params, context)
  |> result.map_error(db_utils.database_to_procedure_error)
}
