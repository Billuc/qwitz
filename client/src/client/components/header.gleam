import gleam/list
import lustre/element
import lustre/element/html

pub type HeaderProps(a) {
  HeaderProps(
    prefixes: List(element.Element(a)),
    suffixes: List(element.Element(a)),
    title: String,
  )
}

pub fn view(props: HeaderProps(a)) {
  html.div(
    [],
    [props.prefixes, [html.h1([], [html.text(props.title)])], props.suffixes]
      |> list.flatten,
  )
}
