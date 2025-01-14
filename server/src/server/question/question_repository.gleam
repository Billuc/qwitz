import gleam/list
import gleam/result
import server/context
import server/db_utils
import server/log
import server/question/sql
import shared
import shared/question
import youid/uuid

pub fn get(
  params: shared.Uuid,
  context: context.Context,
) -> Result(question.Question, db_utils.DatabaseError) {
  use <- log.time_log("[question] repository get")

  sql.get_question(context.db, db_utils.shared_to_youid(params))
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.then(db_utils.get_one)
  |> result.map(fn(row) {
    question.Question(
      db_utils.youid_to_shared(row.id),
      db_utils.youid_to_shared(row.qwiz_id),
      row.question,
    )
  })
}

pub fn get_by_qwiz_id(
  params: shared.Uuid,
  context: context.Context,
) -> Result(List(question.Question), db_utils.DatabaseError) {
  use <- log.time_log(
    "[question] repository get_by_qwiz_id with " <> params.data,
  )

  sql.get_all_questions(context.db, db_utils.shared_to_youid(params))
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.map(fn(v) {
    use row <- list.map(v.rows)
    question.Question(
      db_utils.youid_to_shared(row.id),
      db_utils.youid_to_shared(row.qwiz_id),
      row.question,
    )
  })
}

pub fn create(
  params: question.CreateQuestion,
  context: context.Context,
) -> Result(shared.Uuid, db_utils.DatabaseError) {
  use <- log.time_log("[question] repository create")

  let id = uuid.v4()

  sql.create_question(
    context.db,
    id,
    db_utils.shared_to_youid(params.qwiz_id),
    params.question,
  )
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.replace(db_utils.youid_to_shared(id))
}

pub fn update(
  params: question.Question,
  context: context.Context,
) -> Result(shared.Uuid, db_utils.DatabaseError) {
  use <- log.time_log("[question] repository update")

  sql.update_question(
    context.db,
    params.question,
    db_utils.shared_to_youid(params.id),
  )
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.replace(params.id)
}

pub fn delete(
  params: shared.Uuid,
  context: context.Context,
) -> Result(Nil, db_utils.DatabaseError) {
  use <- log.time_log("[question] repository delete")

  sql.delete_question(context.db, db_utils.shared_to_youid(params))
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.replace(Nil)
}
