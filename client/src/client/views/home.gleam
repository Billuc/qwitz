import client/model
import client/msg
import lustre/element
import lustre/element/html
import lustre/event

pub fn view(model: model.Model) -> element.Element(msg.Msg) {
  html.button([event.on("click", fn(_) { Ok(msg.Login("", "")) })], [
    html.text("Login"),
  ])
}
