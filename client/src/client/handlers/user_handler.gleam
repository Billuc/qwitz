import client/model/model
import client/services/user_service
import lustre/effect

pub fn handle_message(
  model: model.Model,
  msg: model.UserMsg,
) -> #(model.Model, effect.Effect(model.Msg)) {
  case msg {
    model.Login(username, password) -> #(
      model,
      effect.from(fn(dispatch) {
        use user <- user_service.login(username, password)
        model.SetUser(user) |> dispatch
      }),
    )
  }
}

pub fn login(user: String, password: String) -> model.Msg {
  model.Login(user, password) |> model.UserMsg
}
