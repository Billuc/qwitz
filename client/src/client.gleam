import client/handlers/answer_handler
import client/handlers/question_handler
import client/handlers/qwiz_handler
import client/handlers/user_handler
import client/model/model
import client/model/route
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
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_) -> #(model.Model, effect.Effect(model.Msg)) {
  let initial_route =
    modem.initial_uri()
    |> result.map(route.on_url_change)
    |> result.unwrap(route.HomeRoute)

  #(
    model.Model(
      user: option.None,
      qwizes: [],
      route: route.HomeRoute,
      qwiz: option.None,
      question: option.None,
    ),
    effect.batch([
      modem.init(fn(uri) { uri |> route.on_url_change |> model.ChangeRoute }),
      case initial_route {
        route.HomeRoute -> effect.none()
        _ -> route.go_to(route.HomeRoute)
      },
    ]),
  )
}

fn update(
  model: model.Model,
  msg: model.Msg,
) -> #(model.Model, effect.Effect(model.Msg)) {
  case msg {
    model.ChangeRoute(route) -> #(
      model.Model(..model, route:),
      model.on_load(route),
    )
    model.SetUser(user) -> #(
      model.Model(..model, user: option.Some(user)),
      route.go_to(route.QwizesRoute),
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
  case model.route {
    route.HomeRoute -> home.view(model)
    route.QwizesRoute -> qwizes_view.view(model)
    route.CreateQwizRoute -> create_qwiz.view(model)
    route.QwizRoute(_) -> qwiz_view.view(model)
    route.CreateQuestionRoute -> create_question.view(model.qwiz)
    route.QuestionRoute(_) -> question_view.view(model)
    route.CreateAnswerRoute -> create_answer.view(model.question)
    route.UpdateAnswerRoute(id) -> edit_answer.view(model, id)
    route.UpdateQuestionRoute(_id) -> edit_question.view(model)
    route.UpdateQwizRoute(_id) -> edit_qwiz.view(model)
  }
}
