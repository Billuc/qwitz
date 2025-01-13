import client/services/qwiz_service
import gleam/option
import gleam/uri
import lustre/effect
import shared
import shared/question
import shared/qwiz
import shared/user

pub type Model {
  Model(
    route: Route,
    user: option.Option(user.User),
    qwizes: List(qwiz.Qwiz),
    qwiz: option.Option(qwiz.QwizWithQuestions),
  )
}

pub type Msg {
  Login(username: String, password: String)
  SetUser(user: user.User)
  ChangeRoute(route: Route)
  SetQwizes(qwizes: List(qwiz.Qwiz))
  CreateQwiz(name: String, owner: shared.Uuid)
  QwizCreated(qwiz: qwiz.QwizWithQuestions)
  SetQwiz(qwiz: qwiz.QwizWithQuestions)
  DeleteQwiz(id: shared.Uuid)
  QwizDeleted(id: shared.Uuid)
  CreateQuestion(qwiz_id: shared.Uuid, question: String)
  QuestionCreated(question.QuestionWithAnswers)
  DeleteQuestion(id: shared.Uuid)
  QuestionDeleted(id: shared.Uuid)
}

pub type Route {
  HomeRoute
  QwizesRoute
  CreateQwizRoute
  QwizRoute(id: shared.Uuid)
  CreateQuestionRoute
}

pub fn on_url_change(uri: uri.Uri) -> Route {
  case uri.path_segments(uri.path) {
    ["qwizes"] -> QwizesRoute
    ["qwizes", "create"] -> CreateQwizRoute
    ["qwiz", id] -> QwizRoute(shared.Uuid(id))
    ["questions", "create"] -> CreateQuestionRoute
    _ -> HomeRoute
  }
}

pub fn route_to_url(route: Route) -> String {
  case route {
    CreateQuestionRoute -> "/questions/create"
    CreateQwizRoute -> "/qwizes/create"
    HomeRoute -> "/"
    QwizRoute(id) -> "/qwiz/" <> id.data
    QwizesRoute -> "/qwizes"
  }
}

pub fn route_on_load(route: Route) -> effect.Effect(Msg) {
  case route {
    QwizesRoute -> {
      use qwizes <- qwiz_service.get_qwizes()
      SetQwizes(qwizes)
    }
    QwizRoute(id) -> {
      use qw <- qwiz_service.get_qwiz(id)
      SetQwiz(qw)
    }
    _ -> effect.none()
  }
}
