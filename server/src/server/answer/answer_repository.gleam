import gleam/list
import gleam/result
import server/answer/sql
import server/context
import server/db_utils
import server/log
import shared
import shared/answer
import youid/uuid

pub fn get(
  params: shared.Uuid,
  context: context.Context,
) -> Result(answer.Answer, db_utils.DatabaseError) {
  use <- log.time_log("[answer] repository get")

  sql.get_answer(context.db, db_utils.shared_to_youid(params))
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.then(db_utils.get_one)
  |> result.map(fn(row) {
    answer.Answer(
      db_utils.youid_to_shared(row.id),
      db_utils.youid_to_shared(row.question_id),
      row.answer,
      row.correct,
    )
  })
}

pub fn get_by_question_id(
  params: shared.Uuid,
  context: context.Context,
) -> Result(List(answer.Answer), db_utils.DatabaseError) {
  use <- log.time_log(
    "[answer] repository get_by_question_id with " <> params.data,
  )

  sql.get_all_answers(context.db, db_utils.shared_to_youid(params))
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.map(fn(v) {
    use row <- list.map(v.rows)
    answer.Answer(
      db_utils.youid_to_shared(row.id),
      db_utils.youid_to_shared(row.question_id),
      row.answer,
      row.correct,
    )
  })
}

pub fn create(
  params: answer.CreateAnswer,
  context: context.Context,
) -> Result(shared.Uuid, db_utils.DatabaseError) {
  use <- log.time_log("[answer] repository create")

  let id = uuid.v4()

  sql.create_answer(
    context.db,
    id,
    db_utils.shared_to_youid(params.question_id),
    params.answer,
    params.correct,
  )
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.then(db_utils.get_one)
  |> result.replace(db_utils.youid_to_shared(id))
}

pub fn update(
  params: answer.Answer,
  context: context.Context,
) -> Result(shared.Uuid, db_utils.DatabaseError) {
  use <- log.time_log("[answer] repository update")

  sql.update_answer(
    context.db,
    params.answer,
    params.correct,
    db_utils.shared_to_youid(params.id),
  )
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.then(db_utils.get_one)
  |> result.replace(params.id)
}

pub fn delete(
  params: shared.Uuid,
  context: context.Context,
) -> Result(Nil, db_utils.DatabaseError) {
  use <- log.time_log("[answer] repository delete")

  sql.delete_answer(context.db, db_utils.shared_to_youid(params))
  |> result.map_error(db_utils.query_error_to_database_error)
  |> result.replace(Nil)
}
