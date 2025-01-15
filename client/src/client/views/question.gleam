import client/handlers/answer_handler
import client/handlers/question_handler
import client/model/model
import client/model/route
import client/views/common
import gleam/list
import gleam/option
import lustre/element
import lustre/element/html
import lustre/event
import shared
import shared/answer

pub fn view(model: model.Model) -> element.Element(model.Msg) {
  case model.question {
    option.None -> common.loading()
    option.Some(question) -> {
      html.div([], [
        html.div([], [
          back_button(model),
          html.h1([], [html.text(question.question)]),
          edit_question_button(question.id),
          delete_question_button(question.id),
        ]),
        answer_list(question.answers),
        create_answer_button(),
      ])
    }
  }
}

fn back_button(model: model.Model) -> element.Element(model.Msg) {
  let return = case model.qwiz {
    option.None -> #(route.QwizesRoute, "Back to qwizes")
    option.Some(qw) -> #(route.QwizRoute(qw.id), "Back to " <> qw.name)
  }

  html.a([route.href(return.0)], [html.text(return.1)])
}

fn answer_list(answers: List(answer.Answer)) -> element.Element(model.Msg) {
  element.keyed(html.div([], _), {
    use a <- list.map(answers)
    #(a.id.data, answer_row(a))
  })
}

fn answer_row(answer: answer.Answer) -> element.Element(model.Msg) {
  html.div([], [
    html.text(answer.answer),
    edit_answer_button(answer.id),
    delete_answer_button(answer.id),
  ])
}

fn edit_answer_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.a([route.href(route.UpdateAnswerRoute(id))], [html.text("Edit")])
}

fn delete_answer_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.button([event.on_click(answer_handler.delete(id))], [html.text("Remove")])
}

fn edit_question_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.a([route.href(route.UpdateQuestionRoute(id))], [html.text("Edit")])
}

fn delete_question_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.button([event.on_click(question_handler.delete(id))], [
    html.text("Delete"),
  ])
}

fn create_answer_button() -> element.Element(model.Msg) {
  html.a([route.href(route.CreateAnswerRoute)], [html.text("Add answer")])
}
