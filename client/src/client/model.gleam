import gleam/option
import shared/qwiz
import shared/user

pub type Model {
  Model(user: option.Option(user.User), qwizes: List(qwiz.Qwiz))
}
