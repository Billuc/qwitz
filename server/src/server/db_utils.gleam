import envoy
import gleam/int
import gleam/result
import gleam/string
import gleamrpc
import pog
import server/context
import server/log
import shared
import youid/uuid

pub type DatabaseError {
  DatabaseError(message: String)
}

pub fn init_db(on_success: fn(pog.Connection) -> Nil) {
  use db_uri <- log.assert_or_log(
    envoy.get("DATABASE_URL"),
    "Couldn't get DATABASE_URL from environment",
  )

  use db <- log.assert_or_log(
    db_uri
      |> pog.url_config,
    "Invalid config from uri " <> db_uri,
  )

  log.log("Connected to the database at " <> db_uri)
  on_success(db |> pog.connect)
}

pub fn shared_to_youid(uuid: shared.Uuid) -> uuid.Uuid {
  let assert Ok(new_uuid) = uuid.from_string(uuid.data)
    as "Decoded UUIDs should be valid"
  new_uuid
}

pub fn youid_to_shared(uuid: uuid.Uuid) -> shared.Uuid {
  shared.Uuid(uuid |> uuid.to_string())
}

pub fn get_one(res: pog.Returned(a)) -> Result(a, DatabaseError) {
  case res.rows {
    [] -> Error(DatabaseError("Result not found"))
    [v, ..] -> Ok(v)
  }
}

pub fn get_all(res: pog.Returned(a)) -> List(a) {
  res.rows
}

pub fn transaction(
  context: context.Context,
  callback: fn(pog.Connection) -> Result(r, pog.QueryError),
) -> Result(r, DatabaseError) {
  {
    use db <- pog.transaction(context.db)

    callback(db)
    |> result.map_error(query_error_to_string)
  }
  |> result.map_error(transaction_error_to_database_error)
}

pub fn query_error_to_database_error(err: pog.QueryError) -> DatabaseError {
  let message = query_error_to_string(err)
  log.log_error(message)
  DatabaseError(message)
}

fn query_error_to_string(err: pog.QueryError) -> String {
  case err {
    pog.ConnectionUnavailable -> "Connection unavailable"
    pog.ConstraintViolated(message, constraint, details) ->
      "Constraint violated : "
      <> message
      <> " ; constraint : "
      <> constraint
      <> " ; details : "
      <> details
    pog.PostgresqlError(code, name, message) ->
      "Postgresql Error [" <> code <> ": " <> name <> "] : " <> message
    pog.QueryTimeout -> "Query Timeout"
    pog.UnexpectedArgumentCount(expected, got) ->
      "Unexpected Argument Count : "
      <> int.to_string(got)
      <> " instead of "
      <> int.to_string(expected)
    pog.UnexpectedArgumentType(expected, got) ->
      "Unexpected Argument Type : " <> got <> " instead of " <> expected
    pog.UnexpectedResultType(decode_errors) ->
      "Unexpected Result Type : " <> string.inspect(decode_errors)
  }
}

fn transaction_error_to_database_error(
  err: pog.TransactionError,
) -> DatabaseError {
  let message = case err {
    pog.TransactionQueryError(q_err) -> query_error_to_string(q_err)
    pog.TransactionRolledBack(reason) -> reason
  }

  log.log_error(message)
  DatabaseError(message)
}

pub fn database_to_procedure_error(
  _err: DatabaseError,
) -> gleamrpc.ProcedureError {
  gleamrpc.ProcedureError("Database Error")
}
