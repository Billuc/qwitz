import client/handlers/qwiz_handler
import client/model/model
import client/model/route
import client/model/router
import client/services/qwiz_service
import client/views/common
import gleam/list
import gleam/option
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import shared
import shared/question

pub fn on_load(model: model.Model, param: shared.Uuid) {
  use dispatch <- effect.from
  use qw <- qwiz_service.get_qwiz(param)
  model.SetQwiz(qw) |> dispatch
}

pub fn view(model: model.Model, _query) -> element.Element(model.Msg) {
  case model.qwiz {
    option.None -> common.loading()
    option.Some(qwiz) -> {
      html.div([], [
        html.div([], [
          back_button(),
          html.h1([], [html.text(qwiz.name)]),
          edit_qwiz_button(qwiz.id),
          delete_qwiz_button(qwiz.id),
        ]),
        question_list(qwiz.questions),
        create_question_button(),
      ])
    }
  }
}

fn back_button() -> element.Element(model.Msg) {
  let return = #(route.qwizes(), Nil, "Back to qwizes")

  html.a([router.href(return.0, return.1)], [html.text(return.2)])
}

fn question_list(
  questions: List(question.Question),
) -> element.Element(model.Msg) {
  element.keyed(html.div([], _), {
    use q <- list.map(questions)
    #(q.id.data, question_row(q))
  })
}

fn question_row(question: question.Question) -> element.Element(model.Msg) {
  html.a([router.href(route.question(), question.id)], [
    html.text(question.question),
  ])
}

fn edit_qwiz_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.a([router.href(route.update_qwiz(), id)], [html.text("Edit")])
}

fn delete_qwiz_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.button([event.on_click(qwiz_handler.delete(id))], [html.text("Delete")])
}

fn create_question_button() -> element.Element(model.Msg) {
  html.a([router.href(route.create_question(), Nil)], [
    html.text("Add question"),
  ])
}
