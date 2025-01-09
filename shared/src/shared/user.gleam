import convert
import gleam/option
import gleamrpc
import shared

pub type User {
  User(id: shared.Uuid, pseudo: String)
}

pub type LoginData {
  LoginData(pseudo: String, password: String)
}

pub fn user_converter() -> convert.Converter(User) {
  convert.object({
    use id <- convert.field(
      "id",
      fn(v: User) { Ok(v.id) },
      shared.uuid_converter(),
    )
    use pseudo <- convert.field(
      "pseudo",
      fn(v: User) { Ok(v.pseudo) },
      convert.string(),
    )

    convert.success(User(id:, pseudo:))
  })
}

pub fn login_data_converter() -> convert.Converter(LoginData) {
  convert.object({
    use pseudo <- convert.field(
      "pseudo",
      fn(v: LoginData) { Ok(v.pseudo) },
      convert.string(),
    )
    use password <- convert.field(
      "password",
      fn(v: LoginData) { Ok(v.password) },
      convert.string(),
    )

    convert.success(LoginData(pseudo:, password:))
  })
}

pub fn login() -> gleamrpc.Procedure(LoginData, User) {
  gleamrpc.query("login", option.None)
  |> gleamrpc.params(login_data_converter())
  |> gleamrpc.returns(user_converter())
}
