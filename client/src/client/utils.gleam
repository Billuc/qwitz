import gleamrpc
import gleamrpc/http/client
import lustre/effect
import plinth/javascript/console

pub fn client() -> gleamrpc.ProcedureClient(
  a,
  b,
  client.GleamRpcHttpClientError,
) {
  client.http_client("http://localhost:8080")
}

pub fn rpc_effect(
  procedure: gleamrpc.Procedure(a, b),
  data: a,
  to_msg: fn(b) -> m,
) -> effect.Effect(m) {
  effect.from(fn(dispatch) {
    let procedure_call = procedure |> gleamrpc.with_client(client())
    use result <- gleamrpc.call(procedure_call, data)

    case result {
      Error(err) -> console.error(err)
      Ok(return) -> dispatch(to_msg(return))
    }
  })
}
