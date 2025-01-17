import client/model/model
import client/model/route
import client/model/router
import client/services/qwiz_service
import gleam/list
import lustre/effect
import lustre/element
import lustre/element/html
import shared/qwiz

pub fn on_load(model: model.Model, _param) {
  use dispatch <- effect.from
  use qwizes <- qwiz_service.get_qwizes()
  model.SetQwizes(qwizes) |> dispatch
}

pub fn view(model: model.Model, _query) {
  html.div([], [
    element.keyed(html.div([], _), {
      use qwiz <- list.map(model.qwizes)
      #(qwiz.id.data, qwiz_row(qwiz))
    }),
    create_qwiz_button(),
  ])
}

fn qwiz_row(qwiz: qwiz.Qwiz) {
  html.div([], [
    html.a([router.href(route.qwiz(), qwiz.id)], [html.text(qwiz.name)]),
  ])
}

pub fn create_qwiz_button() {
  html.a([router.href(route.create_qwiz(), Nil)], [html.text("Create Qwiz")])
}
