import client/model
import client/services/answer_service
import client/services/question_service
import client/services/qwiz_service
import client/services/user_service
import client/views/create_answer
import client/views/create_question
import client/views/create_qwiz
import client/views/edit_answer
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
    |> result.map(model.on_url_change)
    |> result.unwrap(model.HomeRoute)

  #(
    model.Model(
      user: option.None,
      qwizes: [],
      route: model.HomeRoute,
      qwiz: option.None,
      question: option.None,
    ),
    effect.batch([
      modem.init(fn(uri) { uri |> model.on_url_change |> model.ChangeRoute }),
      case initial_route {
        model.HomeRoute -> effect.none()
        _ ->
          modem.push(
            model.HomeRoute |> model.route_to_url,
            option.None,
            option.None,
          )
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
      modem.push(
        model.QwizesRoute |> model.route_to_url,
        option.None,
        option.None,
      ),
    )
    model.SetQwizes(qwizes) -> #(model.Model(..model, qwizes:), effect.none())
    model.CreateQwiz(name, owner) -> #(model, {
      use new_qwiz <- qwiz_service.create_qwiz(name, owner)
      model.QwizCreated(new_qwiz)
    })
    model.QwizCreated(qwiz) -> #(
      model,
      modem.push(
        model.QwizRoute(qwiz.id) |> model.route_to_url,
        option.None,
        option.None,
      ),
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
    model.QwizDeleted(_) -> #(
      model,
      modem.push(
        model.QwizesRoute |> model.route_to_url,
        option.None,
        option.None,
      ),
    )
    model.CreateQuestion(qwiz_id, question) -> #(model, {
      use question <- question_service.create_question(qwiz_id, question)
      model.QuestionCreated(question)
    })
    model.QuestionCreated(question) -> #(
      model,
      modem.push(
        model.QuestionRoute(question.id) |> model.route_to_url,
        option.None,
        option.None,
      ),
    )
    model.DeleteQuestion(id) -> #(model, {
      use _ <- question_service.delete_question(id)
      model.QuestionDeleted(id)
    })
    model.QuestionDeleted(_) -> #(model, case model.qwiz {
      option.None ->
        modem.push(
          model.QwizesRoute |> model.route_to_url,
          option.None,
          option.None,
        )
      option.Some(qwiz) ->
        modem.push(
          model.QwizRoute(qwiz.id) |> model.route_to_url,
          option.None,
          option.None,
        )
    })
    model.SetQuestion(question) -> #(
      model.Model(..model, question: option.Some(question)),
      effect.none(),
    )
    model.CreateAnswer(question_id, answer, correct) -> #(model, {
      use a <- answer_service.create_answer(question_id, answer, correct)
      model.AnswerCreated(a)
    })
    model.AnswerCreated(_) -> #(model, case model.question {
      option.None ->
        modem.push(
          model.QwizesRoute |> model.route_to_url,
          option.None,
          option.None,
        )
      option.Some(question) ->
        modem.push(
          model.QuestionRoute(question.id) |> model.route_to_url,
          option.None,
          option.None,
        )
    })
    model.DeleteAnswer(id) -> #(model, {
      use _ <- answer_service.delete_answer(id)
      model.AnswerDeleted(id)
    })
    model.AnswerDeleted(id) -> #(
      model.Model(
        ..model,
        question: model.question
          |> option.map(fn(q) {
            question.QuestionWithAnswers(
              ..q,
              answers: q.answers |> list.filter(fn(a) { a.id != id }),
            )
          }),
      ),
      effect.none(),
    )
    model.UpdateAnswer(a) -> #(model, {
      use a <- answer_service.update_answer(a)
      model.AnswerUpdated(a)
    })
    model.AnswerUpdated(a) -> #(
      model,
      modem.push(
        model.QuestionRoute(a.question_id) |> model.route_to_url,
        option.None,
        option.None,
      ),
    )
  }
}

fn view(model: model.Model) -> element.Element(model.Msg) {
  case model.route {
    model.HomeRoute -> home.view(model)
    model.QwizesRoute -> qwizes_view.view(model)
    model.CreateQwizRoute -> create_qwiz.view(model)
    model.QwizRoute(_) -> qwiz_view.view(model)
    model.CreateQuestionRoute -> create_question.view(model.qwiz)
    model.QuestionRoute(_) -> question_view.view(model)
    model.CreateAnswerRoute -> create_answer.view(model.question)
    model.UpdateAnswerRoute(id) -> edit_answer.view(model, id)
  }
}
