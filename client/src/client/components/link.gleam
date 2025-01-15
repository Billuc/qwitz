import client/model/model
import client/model/route
import client/model/router
import lustre/element/html

pub type LinkProps {
  LinkProps(
    router: router.Router(route.Route, model.Model, model.Msg),
    to: route.Route,
    query: List(#(String, String)),
    text: String,
  )
}

pub fn view(props: LinkProps) {
  html.a([props.router |> router.href(props.to, props.query)], [
    html.text(props.text),
  ])
}
