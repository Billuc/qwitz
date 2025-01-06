import gleam/result
import gleamrpc
import server
import shared/user
import youid/uuid

const uuid = "ba98a633-dcfe-44d2-97c4-ef4885af08bf"

pub fn register_user_service(
  server: gleamrpc.ProcedureServerInstance(_, _, server.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, server.Context, _) {
  server
  |> gleamrpc.with_implementation(user.login(), login)
}

fn login(
  _data: user.LoginData,
  _ctx: server.Context,
) -> Result(user.User, gleamrpc.ProcedureError) {
  uuid
  |> uuid.from_string
  |> result.replace_error(gleamrpc.ProcedureError("Invalid UUID : " <> uuid))
  |> result.map(user.User(_, "Bob"))
}
