import client/handlers/qwiz_handler
import client/model/model
import client/utils
import gleam/dynamic
import gleam/io
import gleam/option
import gleam/result
import lustre/attribute
import lustre/element as le
import lustre/element/html
import lustre/event

const qwiz_name = "qwiz_name"

pub fn view(model: model.Model, _param) -> le.Element(model.Msg) {
  html.form([event.on("submit", on_submit(model, _))], [
    html.label([], [html.text("Name"), html.input([attribute.id(qwiz_name)])]),
    html.input([attribute.type_("submit"), attribute.value("Create")]),
  ])
}

fn on_submit(
  model: model.Model,
  v: dynamic.Dynamic,
) -> Result(model.Msg, List(dynamic.DecodeError)) {
  event.prevent_default(v)

  case model.user {
    option.None -> {
      io.println_error("No user logged in ! Log in before")
      Error([dynamic.DecodeError("", "No user", [])])
    }
    option.Some(user) -> {
      use name <- result.try(
        utils.get_element(qwiz_name)
        |> result.then(utils.get_value),
      )

      qwiz_handler.create(name, user.id) |> Ok
    }
  }
}
