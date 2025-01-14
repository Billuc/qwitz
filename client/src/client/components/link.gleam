import client/model/route
import lustre/element/html

pub type LinkProps {
  LinkProps(to: route.Route, text: String)
}

pub fn view(props: LinkProps) {
  html.a([route.href(props.to)], [html.text(props.text)])
}
