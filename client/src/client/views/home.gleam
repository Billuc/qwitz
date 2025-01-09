import client/model
import client/msg
import lustre/element
import lustre/element/html

pub fn view(model: model.Model) -> element.Element(msg.Msg) {
  html.h1([], [html.text("Coucou")])
}
