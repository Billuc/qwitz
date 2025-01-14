import lustre/attribute
import lustre/element/html

pub type SubmitProps {
  SubmitProps(text: String)
}

pub fn view(props: SubmitProps) {
  html.input([attribute.type_("submit"), attribute.value(props.text)])
}
