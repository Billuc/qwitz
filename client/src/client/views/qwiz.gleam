import client/model
import client/views/common
import gleam/list
import gleam/option
import lustre/element
import lustre/element/html
import lustre/event
import shared
import shared/question

pub fn view(model: model.Model) {
  case model.qwiz {
    option.None -> common.loading()
    option.Some(qwiz) -> {
      html.div([], [
        html.div([], [
          back_button(model),
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

fn back_button(model: model.Model) {
  let return = #(model.QwizesRoute, "Back to qwizes")

  html.a([model.href(return.0)], [html.text(return.1)])
}

fn question_list(questions: List(question.Question)) {
  element.keyed(html.div([], _), {
    use q <- list.map(questions)
    #(q.id.data, question_row(q))
  })
}

fn question_row(question: question.Question) {
  html.a([model.href(model.QuestionRoute(question.id))], [
    html.text(question.question),
  ])
}

fn edit_qwiz_button(id: shared.Uuid) {
  html.a([model.href(model.UpdateQwizRoute(id))], [html.text("Edit")])
}

fn delete_qwiz_button(id: shared.Uuid) {
  html.button([event.on_click(model.DeleteQwiz(id))], [html.text("Delete")])
}

fn create_question_button() {
  html.a([model.href(model.CreateQuestionRoute)], [html.text("Add question")])
}
