import client/handlers/user_handler
import client/model/model
import lustre/element
import lustre/element/html
import lustre/event

pub fn view(model: model.Model) -> element.Element(model.Msg) {
  html.button([event.on("click", fn(_) { user_handler.login("", "") |> Ok })], [
    html.text("Login"),
  ])
}
