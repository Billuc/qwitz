import client/model/model
import client/model/route
import client/services/answer_service
import client/services/question_service
import client/services/qwiz_service
import client/services/user_service
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
import gleam/list
import gleam/option
import gleam/result
import lustre
import lustre/effect
import lustre/element
import modem
import shared/question

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
    model.Login(pseudo, password) -> #(model, {
      use user <- user_service.login(pseudo, password)
      model.SetUser(user)
    })
    model.SetUser(user) -> #(
      model.Model(..model, user: option.Some(user)),
      route.go_to(route.QwizesRoute),
    )
    // model.SetQwizes(qwizes) -> #(model.Model(..model, qwizes:), effect.none())
    // model.CreateQwiz(name, owner) -> #(model, {
    //   use new_qwiz <- qwiz_service.create_qwiz(name, owner)
    //   model.QwizCreated(new_qwiz)
    // })
    // model.QwizCreated(qwiz) -> #(model, model.go_to(model.QwizRoute(qwiz.id)))
    // model.ChangeRoute(route) -> #(
    //   model.Model(..model, route:),
    //   effect.from(fn(dispatch) {
    //     use model_msg <- route.on_load(route)
    //     model_msg |> option.map(model.ModelMsg) |> option.map(dispatch)
    //   }),
    // )
    // model.SetQwiz(qwiz) -> #(
    //   model.Model(..model, qwiz: option.Some(qwiz)),
    //   effect.none(),
    // )
    // model.DeleteQwiz(qwiz_id) -> #(model, {
    //   use _ <- qwiz_service.delete_qwiz(qwiz_id)
    //   model.QwizDeleted(qwiz_id)
    // })
    // model.QwizDeleted(_) -> #(model, model.go_to(model.QwizesRoute))
    // model.CreateQuestion(qwiz_id, question) -> #(model, {
    //   use question <- question_service.create_question(qwiz_id, question)
    //   model.QuestionCreated(question)
    // })
    // model.QuestionCreated(question) -> #(
    //   model,
    //   model.go_to(model.QuestionRoute(question.id)),
    // )
    // model.DeleteQuestion(id) -> #(model, {
    //   use _ <- question_service.delete_question(id)
    //   model.QuestionDeleted(id)
    // })
    // model.QuestionDeleted(_) -> #(model, case model.qwiz {
    //   option.None -> model.go_to(model.QwizesRoute)
    //   option.Some(qwiz) -> model.go_to(model.QwizRoute(qwiz.id))
    // })
    // model.SetQuestion(question) -> #(
    //   model.Model(..model, question: option.Some(question)),
    //   effect.none(),
    // )
    // model.UpdateQuestion(q) -> #(model, {
    //   use q <- question_service.update_question(q)
    //   model.QuestionUpdated(q)
    // })
    // model.QuestionUpdated(q) -> #(model, model.go_to(model.QuestionRoute(q.id)))
    // model.UpdateQwiz(qw) -> #(model, {
    //   use qw <- qwiz_service.update_qwiz(qw)
    //   model.QwizUpdated(qw)
    // })
    // model.QwizUpdated(qw) -> #(model, model.go_to(model.QwizRoute(qw.id)))
    _ -> #(model, effect.none())
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
