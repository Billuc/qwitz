import client/model
import gleam/list
import lustre/element
import lustre/element/html
import shared/qwiz

pub fn view(model: model.Model) {
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
    html.a([model.href(model.QwizRoute(qwiz.id))], [html.text(qwiz.name)]),
  ])
}

pub fn create_qwiz_button() {
  html.a([model.href(model.CreateQwizRoute)], [html.text("Create Qwiz")])
}
