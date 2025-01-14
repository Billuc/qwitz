import gleam/erlang/process
import gleam/io
import gleamrpc
import gleamrpc/http/server as rpc_http
import glisten
import mist
import server/answer/answer_service
import server/context
import server/db_utils
import server/question/question_service
import server/qwiz/qwiz_service
import server/user/user_service

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
  use db <- db_utils.init_db()

  let rpc_server =
    gleamrpc.with_server(rpc_http.http_server())
    |> gleamrpc.with_context(context.Context(_, db))
    |> gleamrpc.with_middleware(
      rpc_http.cors_middleware(
        rpc_http.CorsOrigins(["http://localhost:1234", "http://127.0.0.1:1234"]),
      ),
    )

  let rpc_server =
    rpc_server
    |> user_service.register
    |> qwiz_service.register
    |> question_service.register
    |> answer_service.register

  let mist_server =
    rpc_server
    |> rpc_http.init_mist(8080)
    |> mist.start_http

  case mist_server {
    Error(err) -> log_error(err)
    Ok(_) -> process.sleep_forever()
  }
}
