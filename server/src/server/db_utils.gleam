import gleam/int
import gleam/io
import gleam/string
import gleamrpc
import pog

pub fn get_one(res: pog.Returned(a)) -> Result(a, gleamrpc.ProcedureError) {
  case res.rows {
    [] -> Error(gleamrpc.ProcedureError("Result not found"))
    [v, ..] -> Ok(v)
  }
}

pub fn get_all(res: pog.Returned(a)) -> List(a) {
  res.rows
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
