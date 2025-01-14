import gleam/int
import gleam/io
import gleam/string
import tempo/duration

pub fn log(message: String) {
  io.println(message)
}

pub fn log_error(message: String) {
  io.println_error("[ERROR] " <> message)
}

pub fn time_log(message: String, exec: fn() -> b) -> b {
  log(message <> " START")
  let start = duration.start_monotonic()

  let result = exec()

  let duration = duration.stop_monotonic(start)
  log(
    message
    <> " END in "
    <> duration |> duration.as_milliseconds |> int.to_string
    <> " ms",
  )

  result
}

pub fn log_in_out(message: String, params: a, exec: fn() -> b) -> b {
  log(message <> " with " <> string.inspect(params))
  let result = exec()
  log(message <> " returns " <> string.inspect(params))
  result
}

pub fn time_log_in_out(message: String, params: a, exec: fn() -> b) -> b {
  log(message <> " with " <> string.inspect(params) <> " START")
  let start = duration.start_monotonic()

  let result = exec()

  let duration = duration.stop_monotonic(start)
  log(
    message
    <> " returns "
    <> string.inspect(result)
    <> " in "
    <> duration |> duration.as_milliseconds |> int.to_string
    <> " ms",
  )

  result
}

pub fn assert_or_log(
  result: Result(a, b),
  on_error: String,
  cb: fn(a) -> Nil,
) -> Nil {
  case result {
    Error(_) -> log_error(on_error)
    Ok(data) -> cb(data)
  }
}
