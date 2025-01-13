import gleam/dynamic
import gleam/result
import gleamrpc
import gleamrpc/http/client
import lustre/effect
import plinth/browser/document
import plinth/browser/element
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

pub fn get_element(
  id: String,
) -> Result(element.Element, List(dynamic.DecodeError)) {
  document.get_element_by_id(id)
  |> result.replace_error([
    dynamic.DecodeError("DOM element", "Element not found", [id]),
  ])
}

pub fn get_value(
  element: element.Element,
) -> Result(String, List(dynamic.DecodeError)) {
  element
  |> element.value
  |> result.replace_error([
    dynamic.DecodeError("A value", "", [
      element |> element.get_attribute("id") |> result.unwrap(""),
    ]),
  ])
}

pub fn get_checked(element: element.Element) -> Bool {
  element |> element.get_checked
}
