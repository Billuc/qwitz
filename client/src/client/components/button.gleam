import lustre/element/html
import lustre/event

pub type ButtonProps(msg) {
  ButtonProps(on_click: msg, text: String)
}

pub fn view(props: ButtonProps(msg)) {
  html.button([event.on_click(props.on_click)], [html.text(props.text)])
}
