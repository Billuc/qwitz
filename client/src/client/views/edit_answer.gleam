import client/handlers/answer_handler
import client/model/model
import client/model/route
import client/model/router
import client/utils
import gleam/dynamic
import gleam/list
import gleam/option
import gleam/result
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import shared
import shared/answer

const answer_title = "answer_title"

const answer_correct = "answer_correct"

pub fn view(
  model: model.Model,
  answer_id: shared.Uuid,
) -> element.Element(model.Msg) {
  let answer =
    model.question
    |> option.then(fn(q) {
      q.answers |> list.find(fn(a) { a.id == answer_id }) |> option.from_result
    })

  case answer {
    option.None -> no_answer_view(model)
    option.Some(answer) -> update_view(answer)
  }
}

fn no_answer_view(model: model.Model) -> element.Element(model.Msg) {
  let return = case model.question, model.qwiz {
    option.None, option.None -> #(route.QwizesRoute, [], "Go back to qwizes")
    option.Some(q), _ -> #(
      route.QuestionRoute,
      [#("id", q.id.data)],
      "Go back to " <> q.question,
    )
    option.None, option.Some(qw) -> #(
      route.QwizRoute,
      [#("id", qw.id.data)],
      "Go back to " <> qw.name,
    )
  }

  html.div([], [
    html.h1([], [html.text("Error: No answer selected !")]),
    html.a([model.router |> router.href(return.0, return.1)], [
      html.text(return.2),
    ]),
  ])
}

fn update_view(answer: answer.Answer) -> element.Element(model.Msg) {
  html.div([], [
    html.form([event.on("submit", on_submit(answer, _))], [
      html.label([], [
        html.text("Title"),
        html.input([attribute.id(answer_title), attribute.value(answer.answer)]),
      ]),
      html.label([], [
        html.text("Correct answer ?"),
        html.input([
          attribute.id(answer_correct),
          attribute.type_("checkbox"),
          attribute.checked(answer.correct),
        ]),
      ]),
      html.input([attribute.type_("submit"), attribute.value("Save")]),
    ]),
  ])
}

fn on_submit(answer: answer.Answer, v: dynamic.Dynamic) {
  event.prevent_default(v)

  use title <- result.try(
    utils.get_element(answer_title)
    |> result.then(utils.get_value),
  )
  use correct <- result.try(
    utils.get_element(answer_correct) |> result.map(utils.get_checked),
  )

  answer_handler.update(answer.Answer(..answer, answer: title, correct:)) |> Ok
}
