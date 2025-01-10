import client/utils
import gleam/io
import gleam/option
import gleam/uri
import lustre/effect
import shared
import shared/qwiz
import shared/user

pub type Model {
  Model(route: Route, user: option.Option(user.User), qwizes: List(qwiz.Qwiz))
}

pub type Msg {
  Login(username: String, password: String)
  SetUser(user: user.User)
  ChangeRoute(route: Route)
  SetQwizes(qwizes: List(qwiz.Qwiz))
  CreateQwiz(name: String, owner: shared.Uuid)
  QwizCreated(qwiz: qwiz.QwizWithQuestions)
}

pub type Route {
  HomeRoute
  QwizesRoute
  CreateQwizRoute
  QwizRoute
  CreateQuestionRoute
}

pub fn on_url_change(uri: uri.Uri) -> Msg {
  case uri.path_segments(uri.path) {
    ["qwizes"] -> ChangeRoute(QwizesRoute)
    ["qwizes", "create"] -> ChangeRoute(CreateQwizRoute)
    _ -> ChangeRoute(HomeRoute)
  }
}

pub fn route_on_load(route: Route) -> effect.Effect(Msg) {
  case route {
    QwizesRoute ->
      utils.rpc_effect(utils.client(), qwiz.get_qwizes(), Nil, SetQwizes)
    _ -> effect.none()
  }
}
