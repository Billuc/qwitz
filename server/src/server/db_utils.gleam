import gleam/int
import gleam/io
import gleam/result
import gleam/string
import gleamrpc
import pog
import server/context
import shared
import youid/uuid

pub fn shared_to_youid(uuid: shared.Uuid) -> uuid.Uuid {
  let assert Ok(new_uuid) = uuid.from_string(uuid.data)
    as "Decoded UUIDs should be valid"
  new_uuid
}

pub fn youid_to_shared(uuid: uuid.Uuid) -> shared.Uuid {
  shared.Uuid(uuid |> uuid.to_string())
}

pub fn get_one(res: pog.Returned(a)) -> Result(a, gleamrpc.ProcedureError) {
  case res.rows {
    [] -> Error(gleamrpc.ProcedureError("Result not found"))
    [v, ..] -> Ok(v)
  }
}

pub fn get_all(res: pog.Returned(a)) -> List(a) {
  res.rows
}

pub fn transaction(
  context: context.Context,
  callback: fn(pog.Connection) -> Result(r, pog.QueryError),
) {
  {
    use db <- pog.transaction(context.db)

    callback(db)
    |> result.map_error(query_error_to_string)
  }
  |> result.map_error(transaction_error_to_procedure_error)
}

pub fn query_error_to_procedure_error(
  err: pog.QueryError,
) -> gleamrpc.ProcedureError {
  case err {
    pog.ConnectionUnavailable -> {
      io.println_error("Connection unavailable")
      gleamrpc.ProcedureError("Couldn't connect to database")
    }
    pog.ConstraintViolated(message, constraint, details) -> {
      io.println_error(
        "Constraint violated : "
        <> message
        <> " ; constraint : "
        <> constraint
        <> " ; details : "
        <> details,
      )
      gleamrpc.ProcedureError("Database Error")
    }
    pog.PostgresqlError(code, name, message) -> {
      io.println_error(
        "Postgresql Error [" <> code <> ": " <> name <> "] : " <> message,
      )
      gleamrpc.ProcedureError("Database Error")
    }
    pog.QueryTimeout -> {
      io.println_error("Query Timeout")
      gleamrpc.ProcedureError("Timeout while connecting to the database")
    }
    pog.UnexpectedArgumentCount(expected, got) -> {
      io.println_error(
        "Unexpected Argument Count : "
        <> int.to_string(got)
        <> " instead of "
        <> int.to_string(expected),
      )
      gleamrpc.ProcedureError("Database Error")
    }
    pog.UnexpectedArgumentType(expected, got) -> {
      io.println_error(
        "Unexpected Argument Type : " <> got <> " instead of " <> expected,
      )
      gleamrpc.ProcedureError("Database Error")
    }
    pog.UnexpectedResultType(decode_errors) -> {
      io.println_error(
        "Unexpected Result Type : " <> string.inspect(decode_errors),
      )
      gleamrpc.ProcedureError("Database Error")
    }
  }
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

fn transaction_error_to_procedure_error(
  err: pog.TransactionError,
) -> gleamrpc.ProcedureError {
  case err {
    pog.TransactionQueryError(q_err) -> query_error_to_string(q_err)
    pog.TransactionRolledBack(reason) -> reason
  }
  |> io.println_error

  gleamrpc.ProcedureError("Database Error ! See logs")
}
