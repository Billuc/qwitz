import client/model
import lustre/element/html

pub type LinkProps {
  LinkProps(to: model.Route, text: String)
}

pub fn view(props: LinkProps) {
  html.a([model.href(props.to)], [html.text(props.text)])
}
