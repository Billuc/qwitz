import client/handlers/user_handler
import client/model/model
import client/model/route
import client/model/router
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

pub fn route_def() -> router.RouteDef(route.Route, model.Model, model.Msg) {
  router.RouteDef(
    route_id: route.HomeRoute,
    path: [],
    on_load: fn(_model, _query) { effect.none() },
    view_fn: view,
  )
}

pub fn view(model: model.Model) -> element.Element(model.Msg) {
  html.button([event.on("click", fn(_) { user_handler.login("", "") |> Ok })], [
    html.text("Login"),
  ])
}
