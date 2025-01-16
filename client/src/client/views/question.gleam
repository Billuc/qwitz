import client/model/model
import client/model/router
import client/model/routes
import client/services/question_service
import client/views/common
import gleam/io
import gleam/list
import gleam/option
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import shared
import shared/answer

pub fn view(model: model.Model, _query) -> element.Element(model.Msg) {
  case model.question {
    option.None -> common.loading()
    option.Some(question) -> {
      html.div([], [
        html.div([], [
          back_button(model),
          html.h1([], [html.text(question.question)]),
          edit_question_button(model, question.id),
          delete_question_button(question.id),
        ]),
        answer_list(model, question.answers),
        create_answer_button(model),
      ])
    }
  }
}

fn back_button(model: model.Model) -> element.Element(model.Msg) {
  let return = case model.qwiz {
    option.None -> #(routes.QwizesRoute, [], "Back to qwizes")
    option.Some(qw) -> #(
      route.QwizRoute,
      [#("id", qw.id.data)],
      "Back to " <> qw.name,
    )
  }

  html.a([router.href(return.0, return.1)], [html.text(return.2)])
}

fn answer_list(
  model: model.Model,
  answers: List(answer.Answer),
) -> element.Element(model.Msg) {
  element.keyed(html.div([], _), {
    use a <- list.map(answers)
    #(a.id.data, answer_row(model, a))
  })
}

fn answer_row(
  model: model.Model,
  answer: answer.Answer,
) -> element.Element(model.Msg) {
  html.div([], [
    html.text(answer.answer),
    edit_answer_button(model, answer.id),
    delete_answer_button(answer.id),
  ])
}

fn edit_answer_button(
  model: model.Model,
  id: shared.Uuid,
) -> element.Element(model.Msg) {
  html.a(
    [model.router |> router.href(route.UpdateAnswerRoute, [#("id", id.data)])],
    [html.text("Edit")],
  )
}

fn delete_answer_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.button([event.on_click(answer_handler.delete(id))], [html.text("Remove")])
}

fn edit_question_button(
  model: model.Model,
  id: shared.Uuid,
) -> element.Element(model.Msg) {
  html.a(
    [model.router |> router.href(route.UpdateQuestionRoute, [#("id", id.data)])],
    [html.text("Edit")],
  )
}

fn delete_question_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.button([event.on_click(question_handler.delete(id))], [
    html.text("Delete"),
  ])
}

fn create_answer_button(model: model.Model) -> element.Element(model.Msg) {
  html.a([model.router |> router.href(route.CreateAnswerRoute, [])], [
    html.text("Add answer"),
  ])
}
