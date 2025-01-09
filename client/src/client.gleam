import client/model
import client/msg
import client/views/home
import lustre
import lustre/effect
import lustre/element

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_) -> #(model.Model, effect.Effect(msg.Msg)) {
  #(model.Model(qwizes: []), effect.none())
}

fn update(
  model: model.Model,
  msg: msg.Msg,
) -> #(model.Model, effect.Effect(msg.Msg)) {
  case msg {
    msg.Msg -> #(model, effect.none())
  }
}

fn view(model: model.Model) -> element.Element(msg.Msg) {
  home.view(model)
}
