import gleam/result
import gleam/string
import gleamrpc
import server/context
import server/log
import shared
import shared/user
import youid/uuid

const uuid = shared.Uuid("ba98a633-dcfe-44d2-97c4-ef4885af08bf")

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  log.log("Registering user procedures")

  server
  |> gleamrpc.with_implementation(user.login(), login)
}

fn login(
  data: user.LoginData,
  _ctx: context.Context,
) -> Result(user.User, gleamrpc.ProcedureError) {
  use <- log.time_log_in_out("[user] login", data)
  Ok(user.User(uuid, "Bob"))
}
