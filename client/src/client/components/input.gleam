import lustre/attribute
import lustre/element/html

pub type InputProps {
  InputProps(id: String, label: String)
}

pub fn view(props: InputProps) {
  html.label([], [html.text(props.label), html.input([attribute.id(props.id)])])
}
