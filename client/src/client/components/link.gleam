import client/model/router
import lustre/element/html

pub type LinkProps(route, param) {
  LinkProps(
    to: router.RouteIdentifier(route, param),
    param: param,
    text: String,
  )
}

pub fn view(props: LinkProps(_, param)) {
  html.a([router.href(props.to, props.param)], [html.text(props.text)])
}
