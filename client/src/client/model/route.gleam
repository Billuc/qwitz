import gleam/option
import gleam/uri
import lustre/attribute
import lustre/effect
import modem
import shared

pub type Route {
  HomeRoute
  QwizesRoute
  CreateQwizRoute
  QwizRoute(id: shared.Uuid)
  CreateQuestionRoute
  QuestionRoute(id: shared.Uuid)
  CreateAnswerRoute
  UpdateAnswerRoute(id: shared.Uuid)
  UpdateQuestionRoute(id: shared.Uuid)
  UpdateQwizRoute(id: shared.Uuid)
}

pub fn on_url_change(uri: uri.Uri) -> Route {
  case uri.path_segments(uri.path) {
    ["qwizes"] -> QwizesRoute
    ["qwizes", "create"] -> CreateQwizRoute
    ["qwiz", id] -> QwizRoute(shared.Uuid(id))
    ["questions", "create"] -> CreateQuestionRoute
    ["question", id] -> QuestionRoute(shared.Uuid(id))
    ["answers", "create"] -> CreateAnswerRoute
    ["answer", "update", id] -> UpdateAnswerRoute(shared.Uuid(id))
    ["question", "update", id] -> UpdateQuestionRoute(shared.Uuid(id))
    ["qwiz", "update", id] -> UpdateQwizRoute(shared.Uuid(id))
    _ -> HomeRoute
  }
}

pub fn to_url(route: Route) -> String {
  case route {
    CreateQuestionRoute -> "/questions/create"
    CreateQwizRoute -> "/qwizes/create"
    HomeRoute -> "/"
    QwizRoute(id) -> "/qwiz/" <> id.data
    QwizesRoute -> "/qwizes"
    QuestionRoute(id) -> "/question/" <> id.data
    CreateAnswerRoute -> "/answers/create"
    UpdateAnswerRoute(id) -> "/answer/update/" <> id.data
    UpdateQuestionRoute(id) -> "/question/update/" <> id.data
    UpdateQwizRoute(id) -> "/qwiz/update/" <> id.data
  }
}

pub fn go_to(route: Route) -> effect.Effect(msg) {
  modem.push(route |> to_url, option.None, option.None)
}

pub fn href(route: Route) -> attribute.Attribute(_) {
  attribute.href(route |> to_url)
}
