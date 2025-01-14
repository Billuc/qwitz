import client/model/model
import client/model/route
import client/utils
import gleam/dynamic
import gleam/option
import gleam/result
import lustre/attribute
import lustre/element as le
import lustre/element/html
import lustre/event
import shared/qwiz

const qwiz_name = "qwiz_name"

pub fn view(model: model.Model) -> le.Element(model.Msg) {
  case model.qwiz {
    option.None -> no_qwiz_view()
    option.Some(qwiz) -> update_view(qwiz)
  }
}

fn no_qwiz_view() {
  html.div([], [
    html.h1([], [html.text("Error: No qwiz selected !")]),
    html.a([route.href(route.QwizesRoute)], [html.text("Go back to qwizes")]),
  ])
}

fn update_view(qwiz: qwiz.QwizWithQuestions) {
  html.form([event.on("submit", on_submit(qwiz, _))], [
    html.label([], [html.text("Name"), html.input([attribute.id(qwiz_name)])]),
    html.input([attribute.type_("submit"), attribute.value("Save")]),
  ])
}

fn on_submit(
  qwiz: qwiz.QwizWithQuestions,
  v: dynamic.Dynamic,
) -> Result(model.Msg, List(dynamic.DecodeError)) {
  event.prevent_default(v)

  use name <- result.try(
    utils.get_element(qwiz_name)
    |> result.then(utils.get_value),
  )

  Ok(model.UpdateQwiz(qwiz.Qwiz(qwiz.id, name, qwiz.owner)))
}
