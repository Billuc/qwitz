import client/model
import client/services/question_service
import client/services/qwiz_service
import client/services/user_service
import client/views/create_question
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
import shared/question
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
      model.Model(..model, qwizes: [
        qwiz.Qwiz(id: qwiz.id, name: qwiz.name, owner: qwiz.owner),
        ..model.qwizes
      ]),
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
    model.QwizDeleted(qwiz_id) -> #(
      model.Model(
        ..model,
        qwizes: model.qwizes |> list.filter(fn(q) { q.id != qwiz_id }),
      ),
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
      model.Model(
        ..model,
        qwiz: model.qwiz
          |> option.map(fn(qw) {
            qwiz.QwizWithQuestions(..qw, questions: [
              question.Question(
                question.id,
                question.qwiz_id,
                question.question,
              ),
              ..qw.questions
            ])
          }),
      ),
      effect.none(),
      // Should move to the question page
    )
    model.DeleteQuestion(id) -> #(model, {
      use _ <- question_service.delete_question(id)
      model.QuestionDeleted(id)
    })
    model.QuestionDeleted(id) -> #(
      model.Model(
        ..model,
        qwiz: model.qwiz
          |> option.map(fn(qw) {
            qwiz.QwizWithQuestions(
              qw.id,
              qw.name,
              qw.owner,
              qw.questions |> list.filter(fn(q) { q.id != id }),
            )
          }),
      ),
      case model.qwiz {
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
      },
    )
  }
}

fn view(model: model.Model) -> element.Element(model.Msg) {
  case model.route {
    model.HomeRoute -> home.view(model)
    model.QwizesRoute -> qwizes_view.view(model)
    model.CreateQwizRoute -> create_qwiz.view(model)
    model.QwizRoute(_) -> qwiz_view.view(model.qwiz)
    model.CreateQuestionRoute -> create_question.view(model.qwiz)
    _ -> home.view(model)
  }
}
