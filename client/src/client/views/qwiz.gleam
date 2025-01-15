import client/handlers/qwiz_handler
import client/model/model
import client/model/route
import client/model/router
import client/views/common
import gleam/list
import gleam/option
import lustre/element
import lustre/element/html
import lustre/event
import shared
import shared/question

pub fn view(model: model.Model) -> element.Element(model.Msg) {
  case model.qwiz {
    option.None -> common.loading()
    option.Some(qwiz) -> {
      html.div([], [
        html.div([], [
          back_button(model),
          html.h1([], [html.text(qwiz.name)]),
          edit_qwiz_button(model, qwiz.id),
          delete_qwiz_button(qwiz.id),
        ]),
        question_list(model, qwiz.questions),
        create_question_button(model),
      ])
    }
  }
}

fn back_button(model: model.Model) -> element.Element(model.Msg) {
  let return = #(route.QwizesRoute, [], "Back to qwizes")

  html.a([model.router |> router.href(return.0, return.1)], [
    html.text(return.2),
  ])
}

fn question_list(
  model: model.Model,
  questions: List(question.Question),
) -> element.Element(model.Msg) {
  element.keyed(html.div([], _), {
    use q <- list.map(questions)
    #(q.id.data, question_row(model, q))
  })
}

fn question_row(
  model: model.Model,
  question: question.Question,
) -> element.Element(model.Msg) {
  html.a(
    [
      model.router
      |> router.href(route.QuestionRoute, [#("id", question.id.data)]),
    ],
    [html.text(question.question)],
  )
}

fn edit_qwiz_button(
  model: model.Model,
  id: shared.Uuid,
) -> element.Element(model.Msg) {
  html.a(
    [model.router |> router.href(route.UpdateQwizRoute, [#("id", id.data)])],
    [html.text("Edit")],
  )
}

fn delete_qwiz_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.button([event.on_click(qwiz_handler.delete(id))], [html.text("Delete")])
}

fn create_question_button(model: model.Model) -> element.Element(model.Msg) {
  html.a([model.router |> router.href(route.CreateQuestionRoute, [])], [
    html.text("Add question"),
  ])
}
