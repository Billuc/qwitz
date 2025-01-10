import client/model
import gleam/list
import lustre/attribute
import lustre/element/html
import shared/qwiz

pub fn view(model: model.Model) {
  html.div([], [
    html.div([], {
      use qwiz <- list.map(model.qwizes)
      qwiz_row(qwiz)
    }),
    create_qwiz_button(),
  ])
}

fn qwiz_row(qwiz: qwiz.Qwiz) {
  html.div([], [html.text(qwiz.name)])
}

pub fn create_qwiz_button() {
  html.a([attribute.href("/qwizes/create")], [html.text("Create Qwiz")])
}
