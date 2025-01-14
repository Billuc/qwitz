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

pub fn view(model: model.Model) {
  case model.question {
    option.None -> common.loading()
    option.Some(question) -> {
      html.div([], [
        html.div([], [
          back_button(model),
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

fn back_button(model: model.Model) {
  let return = case model.qwiz {
    option.None -> #(model.QwizesRoute, "Back to qwizes")
    option.Some(qw) -> #(model.QwizRoute(qw.id), "Back to " <> qw.name)
  }

  html.a([attribute.href(return.0 |> model.route_to_url)], [html.text(return.1)])
}

fn answer_list(answers: List(answer.Answer)) {
  element.keyed(html.div([], _), {
    use a <- list.map(answers)
    #(a.id.data, answer_row(a))
  })
}

fn answer_row(answer: answer.Answer) {
  html.div([], [
    html.text(answer.answer),
    edit_answer_button(answer.id),
    delete_answer_button(answer.id),
  ])
}

fn edit_answer_button(id: shared.Uuid) {
  html.a([attribute.href(model.UpdateAnswerRoute(id) |> model.route_to_url)], [
    html.text("Edit"),
  ])
}

fn delete_answer_button(id: shared.Uuid) {
  html.button([event.on_click(model.DeleteAnswer(id))], [html.text("Remove")])
}

fn delete_question_button(id: shared.Uuid) {
  html.button([event.on_click(model.DeleteQuestion(id))], [html.text("Delete")])
}

fn create_answer_button() {
  html.a([attribute.href(model.CreateAnswerRoute |> model.route_to_url)], [
    html.text("Add answer"),
  ])
}
