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
import lustre
import lustre/effect
import lustre/element

pub fn main() {
  let router =
    router.init(
      fn(route_data) { model.ChangeRoute(route_data.0, route_data.1) },
      router.std_error_page(),
      route.ErrorRoute,
    )
    |> router.register(route.home(), router.no_load, home.view)
    |> router.register(route.qwizes(), qwizes_view.on_load, qwizes_view.view)
    |> router.register(route.qwiz(), qwiz_view.on_load, qwiz_view.view)
    |> router.register(
      route.question(),
      question_view.on_load,
      question_view.view,
    )
    |> router.register(route.create_qwiz(), router.no_load, create_qwiz.view)
    |> router.register(
      route.create_question(),
      router.no_load,
      create_question.view,
    )
    |> router.register(
      route.create_answer(),
      router.no_load,
      create_answer.view,
    )
    |> router.register(route.update_qwiz(), router.no_load, edit_qwiz.view)
    |> router.register(
      route.update_question(),
      router.no_load,
      edit_question.view,
    )
    |> router.register(route.update_answer(), router.no_load, edit_answer.view)

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
      params: [],
    ),
    router |> router.init_effect(),
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
      router.go_to(route.qwizes(), Nil),
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
  model.router |> router.view(model.route, model, model.params)
}
