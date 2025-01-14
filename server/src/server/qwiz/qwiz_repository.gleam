import gleam/list
import gleam/result
import server/context
import server/db_utils
import server/log
import server/qwiz/sql
import shared
import shared/qwiz
import youid/uuid

pub fn get(
  params: shared.Uuid,
  context: context.Context,
) -> Result(qwiz.Qwiz, db_utils.DatabaseError) {
  use <- log.time_log("[qwiz] repository get")

  sql.get_qwiz(context.db, db_utils.shared_to_youid(params))
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.then(db_utils.get_one)
  |> result.map(fn(row) {
    qwiz.Qwiz(
      db_utils.youid_to_shared(row.id),
      row.name,
      db_utils.youid_to_shared(row.owner),
    )
  })
}

pub fn get_all(
  context: context.Context,
) -> Result(List(qwiz.Qwiz), db_utils.DatabaseError) {
  use <- log.time_log("[qwiz] repository get_all")

  sql.get_all_qwizes(context.db)
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.map(fn(v) {
    use row <- list.map(v.rows)
    qwiz.Qwiz(
      db_utils.youid_to_shared(row.id),
      row.name,
      db_utils.youid_to_shared(row.owner),
    )
  })
}

pub fn create(
  params: qwiz.UpsertQwiz,
  context: context.Context,
) -> Result(shared.Uuid, db_utils.DatabaseError) {
  use <- log.time_log("[qwiz] repository create")

  let id = uuid.v4()

  sql.create_qwiz(
    context.db,
    id,
    params.name,
    db_utils.shared_to_youid(params.owner),
  )
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.replace(db_utils.youid_to_shared(id))
}

pub fn update(
  params: qwiz.Qwiz,
  context: context.Context,
) -> Result(shared.Uuid, db_utils.DatabaseError) {
  use <- log.time_log("[qwiz] repository update")

  sql.update_qwiz(context.db, params.name, db_utils.shared_to_youid(params.id))
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.replace(params.id)
}

pub fn delete(
  params: shared.Uuid,
  context: context.Context,
) -> Result(Nil, db_utils.DatabaseError) {
  use <- log.time_log("[qwiz] repository delete")

  sql.delete_qwiz(context.db, db_utils.shared_to_youid(params))
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.replace(Nil)
}
