import client/model/model
import client/model/route
import client/utils
import gleam/dynamic
import gleam/option
import gleam/result
import lustre/attribute
import lustre/element/html
import lustre/event
import shared/question

const question_title = "question_title"

pub fn view(model: model.Model) {
  case model.question {
    option.None -> no_question_view()
    option.Some(question) -> update_view(question)
  }
}

fn no_question_view() {
  html.div([], [
    html.h1([], [html.text("Error: No question selected !")]),
    html.a([route.href(route.QwizesRoute)], [html.text("Go back to qwizes")]),
  ])
}

fn update_view(question: question.QuestionWithAnswers) {
  html.div([], [
    html.form([event.on("submit", on_submit(question, _))], [
      html.label([], [
        html.text("Title"),
        html.input([attribute.id(question_title)]),
      ]),
      html.input([attribute.type_("submit"), attribute.value("Save")]),
    ]),
  ])
}

fn on_submit(question: question.QuestionWithAnswers, v: dynamic.Dynamic) {
  event.prevent_default(v)

  use title <- result.try(
    utils.get_element(question_title)
    |> result.then(utils.get_value),
  )

  Ok(
    model.UpdateQuestion(question.Question(question.id, question.qwiz_id, title)),
  )
}
