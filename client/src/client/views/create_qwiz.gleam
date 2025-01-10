import client/model
import gleam/dynamic
import gleam/io
import gleam/option
import gleam/result
import lustre/attribute
import lustre/element as le
import lustre/element/html
import lustre/event
import plinth/browser/document
import plinth/browser/element

const qwiz_name = "qwiz_name"

pub fn view(model: model.Model) -> le.Element(model.Msg) {
  html.form([event.on("submit", on_submit(model, _))], [
    html.label([], [html.text("Name"), html.input([attribute.id(qwiz_name)])]),
    html.input([attribute.type_("submit"), attribute.value("Create")]),
  ])
}

fn on_submit(
  model: model.Model,
  v: dynamic.Dynamic,
) -> Result(model.Msg, List(dynamic.DecodeError)) {
  io.debug(v)
  event.prevent_default(v)

  case model.user {
    option.None -> Error([dynamic.DecodeError("", "No user", [])])
    option.Some(user) -> {
      get_element(qwiz_name)
      |> result.then(get_value)
      |> result.map(model.CreateQwiz(_, user.id))
    }
  }
}

fn get_element(id: String) -> Result(element.Element, List(dynamic.DecodeError)) {
  document.get_element_by_id(id)
  |> result.replace_error([
    dynamic.DecodeError("DOM element", "Element not found", [id]),
  ])
}

fn get_value(
  element: element.Element,
) -> Result(String, List(dynamic.DecodeError)) {
  element
  |> element.value
  |> result.replace_error([
    dynamic.DecodeError("A value", "", [
      element |> element.get_attribute("id") |> result.unwrap(""),
    ]),
  ])
}
