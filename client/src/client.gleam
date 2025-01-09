import client/model
import client/msg
import client/utils
import client/views/home
import gleam/option
import lustre
import lustre/effect
import lustre/element
import shared/user

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_) -> #(model.Model, effect.Effect(msg.Msg)) {
  #(model.Model(user: option.None, qwizes: []), effect.none())
}

fn update(
  model: model.Model,
  msg: msg.Msg,
) -> #(model.Model, effect.Effect(msg.Msg)) {
  case msg {
    msg.Login(pseudo, password) -> #(
      model,
      utils.rpc_effect(
        utils.client(),
        user.login(),
        user.LoginData(pseudo:, password:),
        msg.SetUser,
      ),
    )
    msg.SetUser(user) -> #(
      model.Model(..model, user: option.Some(user)),
      effect.none(),
    )
  }
}

fn view(model: model.Model) -> element.Element(msg.Msg) {
  home.view(model)
}
