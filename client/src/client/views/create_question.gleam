import client/model
import client/utils
import gleam/dynamic
import gleam/option
import gleam/result
import lustre/attribute
import lustre/element/html
import lustre/event
import shared/qwiz

const question_title = "question_title"

pub fn view(qwiz: option.Option(qwiz.QwizWithQuestions)) {
  case qwiz {
    option.None -> no_qwiz_view()
    option.Some(qwiz) -> create_view(qwiz)
  }
}

fn no_qwiz_view() {
  html.div([], [
    html.h1([], [html.text("Error: No qwiz selected !")]),
    html.a([model.href(model.QwizesRoute)], [html.text("Go back to qwizes")]),
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

  utils.get_element(question_title)
  |> result.then(utils.get_value)
  |> result.map(model.CreateQuestion(qwiz.id, _))
}
