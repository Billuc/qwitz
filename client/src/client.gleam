import client/handlers/answer_handler
import client/handlers/question_handler
import client/handlers/qwiz_handler
import client/handlers/user_handler
import client/model/model
import client/model/route
import client/model/router
import client/views/create_answer
import client/views/create_question
import client/views/create_qwiz
import client/views/edit_answer
import client/views/edit_question
import client/views/edit_qwiz
import client/views/home
import client/views/question as question_view
import client/views/qwiz as qwiz_view
import client/views/qwizes as qwizes_view
import gleam/option
import gleam/result
import lustre
import lustre/effect
import lustre/element
import modem

pub fn main() {
  let router =
    router.init([home.route_def()], home.route_def(), fn(route_data) {
      model.ChangeRoute(route_data.0, route_data.1)
    })

  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", router)
  Nil
}

fn init(
  router: router.Router(route.Route, model.Model, model.Msg),
) -> #(model.Model, effect.Effect(model.Msg)) {
  #(
    model.Model(
      user: option.None,
      qwizes: [],
      route: route.HomeRoute,
      qwiz: option.None,
      question: option.None,
      router:,
    ),
    effect.batch([
      router |> router.init_effect(),
      case router |> router.initial_route() {
        Ok(def) -> effect.none()
        Error(_) -> router |> router.go_to(route.HomeRoute, [])
      },
    ]),
  )
}

fn update(
  model: model.Model,
  msg: model.Msg,
) -> #(model.Model, effect.Effect(model.Msg)) {
  case msg {
    model.ChangeRoute(route, params) -> #(
      model.Model(..model, route:),
      model.router |> router.on_change(route, params, model),
    )
    model.SetUser(user) -> #(
      model.Model(..model, user: option.Some(user)),
      model.router |> router.go_to(route.QwizesRoute, []),
    )
    model.SetQwizes(qwizes) -> #(model.Model(..model, qwizes:), effect.none())
    model.SetQwiz(qwiz) -> #(
      model.Model(..model, qwiz: option.Some(qwiz)),
      effect.none(),
    )
    model.SetQuestion(question) -> #(
      model.Model(..model, question: option.Some(question)),
      effect.none(),
    )

    model.UserMsg(msg) -> user_handler.handle_message(model, msg)
    model.QwizMsg(msg) -> qwiz_handler.handle_message(model, msg)
    model.QuestionMsg(msg) -> question_handler.handle_message(model, msg)
    model.AnswerMsg(msg) -> answer_handler.handle_message(model, msg)
  }
}

fn view(model: model.Model) -> element.Element(model.Msg) {
  model.router |> router.view(model.route, model)
  // case model.route {
  //   route.HomeRoute -> home.view(model)
  //   route.QwizesRoute -> qwizes_view.view(model)
  //   route.CreateQwizRoute -> create_qwiz.view(model)
  //   route.QwizRoute(_) -> qwiz_view.view(model)
  //   route.CreateQuestionRoute -> create_question.view(model.qwiz)
  //   route.QuestionRoute(_) -> question_view.view(model)
  //   route.CreateAnswerRoute -> create_answer.view(model.question)
  //   route.UpdateAnswerRoute(id) -> edit_answer.view(model, id)
  //   route.UpdateQuestionRoute(_id) -> edit_question.view(model)
  //   route.UpdateQwizRoute(_id) -> edit_qwiz.view(model)
  // }
}
