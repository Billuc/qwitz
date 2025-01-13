import client/model
import client/services/qwiz as qwiz_service
import client/services/user_service
import client/views/create_qwiz
import client/views/home
import client/views/qwiz as qwiz_view
import client/views/qwizes as qwizes_view
import gleam/list
import gleam/option
import gleam/result
import lustre
import lustre/effect
import lustre/element
import modem
import shared/qwiz

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_) -> #(model.Model, effect.Effect(model.Msg)) {
  let initial_route =
    modem.initial_uri()
    |> result.map(model.on_url_change)
    |> result.unwrap(model.HomeRoute)

  #(
    model.Model(
      user: option.None,
      qwizes: [],
      route: model.HomeRoute,
      qwiz: option.None,
    ),
    effect.batch([
      modem.init(fn(uri) { uri |> model.on_url_change |> model.ChangeRoute }),
      case initial_route {
        model.HomeRoute -> effect.none()
        _ -> modem.push("/", option.None, option.None)
      },
    ]),
  )
}

fn update(
  model: model.Model,
  msg: model.Msg,
) -> #(model.Model, effect.Effect(model.Msg)) {
  case msg {
    model.Login(pseudo, password) -> #(model, {
      use user <- user_service.login(pseudo, password)
      model.SetUser(user)
    })
    model.SetUser(user) -> #(
      model.Model(..model, user: option.Some(user)),
      modem.push("/qwizes", option.None, option.None),
    )
    model.SetQwizes(qwizes) -> #(model.Model(..model, qwizes:), effect.none())
    model.CreateQwiz(name, owner) -> #(model, {
      use new_qwiz <- qwiz_service.create_qwiz(name, owner)
      model.QwizCreated(new_qwiz)
    })
    model.QwizCreated(qwiz) -> #(
      model.Model(..model, qwizes: [
        qwiz.Qwiz(id: qwiz.id, name: qwiz.name, owner: qwiz.owner),
        ..model.qwizes
      ]),
      modem.push("/qwiz/" <> qwiz.id.data, option.None, option.None),
    )
    model.ChangeRoute(route) -> #(
      model.Model(..model, route:),
      model.route_on_load(route),
    )
    model.SetQwiz(qwiz) -> #(
      model.Model(..model, qwiz: option.Some(qwiz)),
      effect.none(),
    )
    model.DeleteQwiz(qwiz_id) -> #(model, {
      use _ <- qwiz_service.delete_qwiz(qwiz_id)
      model.QwizDeleted(qwiz_id)
    })
    model.QwizDeleted(qwiz_id) -> #(
      model.Model(
        ..model,
        qwizes: model.qwizes |> list.filter(fn(q) { q.id == qwiz_id }),
      ),
      modem.push("/qwizes", option.None, option.None),
    )
  }
}

fn view(model: model.Model) -> element.Element(model.Msg) {
  case model.route {
    model.HomeRoute -> home.view(model)
    model.QwizesRoute -> qwizes_view.view(model)
    model.CreateQwizRoute -> create_qwiz.view(model)
    model.QwizRoute(_) -> qwiz_view.view(model.qwiz)
    _ -> home.view(model)
  }
}
