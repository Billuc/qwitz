import client/model
import lustre/element
import lustre/element/html
import lustre/event

pub fn view(model: model.Model) -> element.Element(model.Msg) {
  html.button([event.on("click", fn(_) { Ok(model.Login("", "")) })], [
    html.text("Login"),
  ])
}
