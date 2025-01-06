import gleam/result
import gleamrpc
import server
import server/db_utils
import server/qwiz/sql
import shared/qwiz
import youid/uuid

pub fn register_user_service(
  server: gleamrpc.ProcedureServerInstance(_, _, server.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, server.Context, _) {
  server
  |> gleamrpc.with_implementation(qwiz.get_qwiz(), get)
}

fn get(
  params: uuid.Uuid,
  context: server.Context,
) -> Result(qwiz.Qwiz, gleamrpc.ProcedureError) {
  sql.get_qwiz(context.db, params)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.then(db_utils.get_one)
  |> result.map(fn(v: sql.GetQwizRow) {
    qwiz.Qwiz(id: v.id, name: v.name, owner: v.owner)
  })
}
