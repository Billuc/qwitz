import client/model/model
import client/model/route
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
    html.a([route.href(route.QwizRoute(qwiz.id))], [html.text(qwiz.name)]),
  ])
}

pub fn create_qwiz_button() {
  html.a([route.href(route.CreateQwizRoute)], [html.text("Create Qwiz")])
}
