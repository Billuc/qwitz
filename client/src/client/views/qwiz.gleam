import client/model
import client/views/common
import gleam/list
import gleam/option
import lustre/element
import lustre/element/html
import lustre/event
import shared
import shared/question
import shared/qwiz

pub fn view(qwiz: option.Option(qwiz.QwizWithQuestions)) {
  case qwiz {
    option.None -> common.not_found()
    option.Some(qwiz) -> {
      html.div([], [
        html.div([], [
          html.h1([], [html.text(qwiz.name), delete_qwiz_button(qwiz.id)]),
        ]),
        question_list(qwiz.questions),
      ])
    }
  }
}

fn question_list(questions: List(question.Question)) {
  element.keyed(html.div([], _), {
    use q <- list.map(questions)
    #(q.id.data, question_row(q))
  })
}

fn question_row(question: question.Question) {
  html.a([], [html.text(question.question)])
}

fn delete_qwiz_button(id: shared.Uuid) {
  html.button([event.on_click(model.DeleteQwiz(id))], [html.text("Delete")])
}
