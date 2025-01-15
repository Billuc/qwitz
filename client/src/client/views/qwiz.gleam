import client/handlers/qwiz_handler
import client/model/model
import client/model/route
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
  let return = #(route.QwizesRoute, "Back to qwizes")

  html.a([route.href(return.0)], [html.text(return.1)])
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
  html.a([route.href(route.QuestionRoute(question.id))], [
    html.text(question.question),
  ])
}

fn edit_qwiz_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.a([route.href(route.UpdateQwizRoute(id))], [html.text("Edit")])
}

fn delete_qwiz_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.button([event.on_click(qwiz_handler.delete(id))], [html.text("Delete")])
}

fn create_question_button() -> element.Element(model.Msg) {
  html.a([route.href(route.CreateQuestionRoute)], [html.text("Add question")])
}
