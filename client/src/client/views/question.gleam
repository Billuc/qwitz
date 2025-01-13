import client/model
import client/views/common
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import shared
import shared/answer
import shared/question

pub fn view(question: option.Option(question.QuestionWithAnswers)) {
  case question {
    option.None -> common.not_found()
    option.Some(question) -> {
      html.div([], [
        html.div([], [
          html.h1([], [
            html.text(question.question),
            delete_question_button(question.id),
          ]),
        ]),
        answer_list(question.answers),
        create_answer_button(),
      ])
    }
  }
}

fn answer_list(answers: List(answer.Answer)) {
  element.keyed(html.div([], _), {
    use a <- list.map(answers)
    #(a.id.data, answer_row(a))
  })
}

fn answer_row(answer: answer.Answer) {
  html.a([], [html.text(answer.answer)])
}

fn delete_question_button(id: shared.Uuid) {
  html.button([event.on_click(model.DeleteQuestion(id))], [html.text("Delete")])
}

fn create_answer_button() {
  html.a([attribute.href(model.CreateAnswerRoute |> model.route_to_url)], [
    html.text("Add answer"),
  ])
}
