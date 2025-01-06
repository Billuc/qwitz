import envoy
import gleam/erlang/process
import gleam/http/request
import gleam/io
import gleam/result
import gleamrpc
import gleamrpc/http/server as rpc_http
import glisten
import mist
import pog

pub type Context {
  Context(req: request.Request(mist.Connection), db: pog.Connection)
}

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
  use db <- result.try(get_db())

  gleamrpc.with_server(rpc_http.http_server())
  |> gleamrpc.with_context(Context(_, db))
  |> rpc_http.init_mist(8080)
  |> mist.start_http
  |> result.map_error(log_error)
  |> result.map(fn(_) { process.sleep_forever() })
}
