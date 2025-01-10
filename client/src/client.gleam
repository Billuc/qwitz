import client/model
import client/utils
import client/views/create_qwiz
import client/views/home
import client/views/qwizes_view
import gleam/io
import gleam/option
import lustre
import lustre/effect
import lustre/element
import modem
import shared/qwiz
import shared/user

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_) -> #(model.Model, effect.Effect(model.Msg)) {
  #(
    model.Model(user: option.None, qwizes: [], route: model.HomeRoute),
    modem.init(model.on_url_change),
  )
}

fn update(
  model: model.Model,
  msg: model.Msg,
) -> #(model.Model, effect.Effect(model.Msg)) {
  case msg {
    model.Login(pseudo, password) -> #(
      model,
      utils.rpc_effect(
        utils.client(),
        user.login(),
        user.LoginData(pseudo:, password:),
        model.SetUser,
      ),
    )
    model.SetUser(user) -> #(
      model.Model(..model, user: option.Some(user)),
      modem.push("/qwizes", option.None, option.None),
    )
    model.SetQwizes(qwizes) -> #(model.Model(..model, qwizes:), effect.none())
    model.CreateQwiz(name, owner) -> #(
      model,
      utils.rpc_effect(
        utils.client(),
        qwiz.create_qwiz(),
        qwiz.UpsertQwiz(name, owner),
        model.QwizCreated,
      ),
    )
    model.QwizCreated(_qwiz) -> #(
      model,
      modem.push("/qwizes", option.None, option.None),
    )
    model.ChangeRoute(route) -> #(
      model.Model(..model, route:),
      model.route_on_load(route),
    )
  }
}

fn view(model: model.Model) -> element.Element(model.Msg) {
  case model.route {
    model.HomeRoute -> home.view(model)
    model.QwizesRoute -> qwizes_view.view(model)
    model.CreateQwizRoute -> create_qwiz.view(model)
    _ -> home.view(model)
  }
}
