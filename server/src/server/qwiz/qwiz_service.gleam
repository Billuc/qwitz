import gleam/list
import gleam/result
import gleamrpc
import server/context
import server/db_utils
import server/qwiz/sql
import shared/qwiz
import youid/uuid

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  server
  |> gleamrpc.with_implementation(qwiz.get_qwiz(), get)
  |> gleamrpc.with_implementation(qwiz.get_qwizes(), get_all)
  |> gleamrpc.with_implementation(qwiz.create_qwiz(), create)
  |> gleamrpc.with_implementation(qwiz.update_qwiz(), update)
  |> gleamrpc.with_implementation(qwiz.delete_qwiz(), delete)
}

fn get(
  params: uuid.Uuid,
  context: context.Context,
) -> Result(qwiz.Qwiz, gleamrpc.ProcedureError) {
  sql.get_qwiz(context.db, params)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.then(db_utils.get_one)
  |> result.map(fn(v: sql.GetQwizRow) {
    qwiz.Qwiz(id: v.id, name: v.name, owner: v.owner)
  })
}

fn get_all(
  _params: Nil,
  context: context.Context,
) -> Result(List(qwiz.Qwiz), gleamrpc.ProcedureError) {
  sql.get_all_qwizes(context.db)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.map(db_utils.get_all)
  |> result.map(fn(v: List(sql.GetAllQwizesRow)) {
    use qwiz_row <- list.map(v)
    qwiz.Qwiz(qwiz_row.id, qwiz_row.name, qwiz_row.owner)
  })
}

fn create(
  params: qwiz.UpsertQwiz,
  context: context.Context,
) -> Result(qwiz.Qwiz, gleamrpc.ProcedureError) {
  let id = uuid.v4()
  sql.create_qwiz(context.db, id, params.name, params.owner)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.then(fn(_) { get(id, context) })
}

fn update(
  params: qwiz.Qwiz,
  context: context.Context,
) -> Result(qwiz.Qwiz, gleamrpc.ProcedureError) {
  sql.update_qwiz(context.db, params.name, params.id)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.then(fn(_) { get(params.id, context) })
}

fn delete(
  params: uuid.Uuid,
  context: context.Context,
) -> Result(Nil, gleamrpc.ProcedureError) {
  sql.delete_qwiz(context.db, params)
  |> result.map_error(db_utils.query_error_to_procedure_error)
  |> result.replace(Nil)
}
