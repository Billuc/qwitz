import client/model/model
import client/model/route
import client/model/router
import gleam/list
import lustre/element
import lustre/element/html
import shared/qwiz

pub fn view(model: model.Model) {
  html.div([], [
    element.keyed(html.div([], _), {
      use qwiz <- list.map(model.qwizes)
      #(qwiz.id.data, qwiz_row(model, qwiz))
    }),
    create_qwiz_button(model),
  ])
}

fn qwiz_row(model: model.Model, qwiz: qwiz.Qwiz) {
  html.div([], [
    html.a(
      [model.router |> router.href(route.QwizRoute, [#("id", qwiz.id.data)])],
      [html.text(qwiz.name)],
    ),
  ])
}

pub fn create_qwiz_button(model: model.Model) {
  html.a([model.router |> router.href(route.CreateQwizRoute, [])], [
    html.text("Create Qwiz"),
  ])
}
