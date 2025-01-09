import gleam/result
import gleamrpc
import server/context
import shared
import shared/user
import youid/uuid

const uuid = shared.Uuid("ba98a633-dcfe-44d2-97c4-ef4885af08bf")

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  server
  |> gleamrpc.with_implementation(user.login(), login)
}

fn login(
  _data: user.LoginData,
  _ctx: context.Context,
) -> Result(user.User, gleamrpc.ProcedureError) {
  Ok(user.User(uuid, "Bob"))
}
