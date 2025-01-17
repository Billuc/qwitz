import client/handlers/question_handler
import client/model/model
import client/model/route
import client/model/router
import client/utils
import gleam/dynamic
import gleam/option
import gleam/result
import lustre/attribute
import lustre/element/html
import lustre/event
import shared/qwiz

const question_title = "question_title"

pub fn view(model: model.Model, _param) {
  case model.qwiz {
    option.None -> no_qwiz_view()
    option.Some(qwiz) -> create_view(qwiz)
  }
}

fn no_qwiz_view() {
  html.div([], [
    html.h1([], [html.text("Error: No qwiz selected !")]),
    html.a([router.href(route.qwizes(), Nil)], [html.text("Go back to qwizes")]),
  ])
}

fn create_view(qwiz: qwiz.QwizWithQuestions) {
  html.div([], [
    html.form([event.on("submit", on_submit(qwiz, _))], [
      html.label([], [
        html.text("Title"),
        html.input([attribute.id(question_title)]),
      ]),
      html.input([attribute.type_("submit"), attribute.value("Create")]),
    ]),
  ])
}

fn on_submit(qwiz: qwiz.QwizWithQuestions, v: dynamic.Dynamic) {
  event.prevent_default(v)

  use title <- result.try(
    utils.get_element(question_title)
    |> result.then(utils.get_value),
  )

  question_handler.create(qwiz.id, title)
  |> Ok
}
