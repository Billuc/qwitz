import envoy
import gleam/erlang/process
import gleam/io
import gleam/result
import gleamrpc
import gleamrpc/http/server as rpc_http
import glisten
import mist
import pog
import server/context
import server/question/question_service
import server/qwiz/qwiz_service
import server/user/user_service

fn get_db() {
  envoy.get("DATABASE_URL")
  |> result.then(pog.url_config)
  |> result.map(pog.connect)
}

fn log_error(error: glisten.StartError) -> Nil {
  let message = case error {
    glisten.AcceptorCrashed(_) -> "Acceptor crashed"
    glisten.AcceptorFailed(_) -> "Acceptor failed"
    glisten.AcceptorTimeout -> "Acceptor timeout"
    glisten.ListenerClosed -> "Listener closed"
    glisten.ListenerTimeout -> "Listener timeout"
    glisten.SystemError(_) -> "System error"
  }
  io.println_error(message)
}

pub fn main() {
  case get_db() {
    Error(Nil) -> io.println_error("Couldn't connect to the database")
    Ok(db) -> {
      gleamrpc.with_server(rpc_http.http_server())
      |> gleamrpc.with_context(context.Context(_, db))
      |> gleamrpc.with_middleware(
        rpc_http.cors_middleware(
          rpc_http.CorsOrigins([
            "http://localhost:1234", "http://127.0.0.1:1234",
          ]),
        ),
      )
      |> user_service.register
      |> qwiz_service.register
      |> question_service.register
      |> rpc_http.init_mist(8080)
      |> mist.start_http
      |> result.map_error(log_error)
      |> result.map(fn(_) { process.sleep_forever() })
      |> result.unwrap_both
    }
  }
}
