import client/handlers/answer_handler
import client/model/model
import client/model/route
import client/model/router
import client/utils
import gleam/dynamic
import gleam/option
import gleam/result
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import shared/question

const answer_title = "answer_title"

const answer_correct = "answer_correct"

pub fn view(model: model.Model) -> element.Element(model.Msg) {
  case model.question {
    option.None -> no_question_view(model)
    option.Some(question) -> create_view(question)
  }
}

fn no_question_view(model: model.Model) {
  html.div([], [
    html.h1([], [html.text("Error: No question selected !")]),
    html.a([model.router |> router.href(route.QwizesRoute, [])], [
      html.text("Go back to qwizes"),
    ]),
  ])
}

fn create_view(question: question.QuestionWithAnswers) {
  html.div([], [
    html.form([event.on("submit", on_submit(question, _))], [
      html.label([], [
        html.text("Title"),
        html.input([attribute.id(answer_title)]),
      ]),
      html.label([], [
        html.text("Correct answer ?"),
        html.input([attribute.id(answer_correct), attribute.type_("checkbox")]),
      ]),
      html.input([attribute.type_("submit"), attribute.value("Create")]),
    ]),
  ])
}

fn on_submit(question: question.QuestionWithAnswers, v: dynamic.Dynamic) {
  event.prevent_default(v)

  use title <- result.try(
    utils.get_element(answer_title)
    |> result.then(utils.get_value),
  )
  use correct <- result.try(
    utils.get_element(answer_correct) |> result.map(utils.get_checked),
  )

  answer_handler.create(question.id, title, correct)
  |> Ok
}
