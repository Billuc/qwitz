import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/uri
import lustre/attribute
import lustre/effect
import lustre/element
import modem

// This is experimental
pub type RouteDef(route, model, msg) {
  RouteDef(
    route_id: route,
    path: List(String),
    on_load: fn(List(#(String, String))) -> effect.Effect(msg),
    view_fn: fn(model) -> element.Element(msg),
  )
}

pub opaque type Router(route, model, msg) {
  Router(
    routes: List(RouteDef(route, model, msg)),
    default_route: RouteDef(route, model, msg),
    to_msg: fn(#(route, List(#(String, String)))) -> msg,
  )
}

pub fn init(
  routes: List(RouteDef(route, model, msg)),
  default_route: RouteDef(route, model, msg),
  to_msg: fn(#(route, List(#(String, String)))) -> msg,
) {
  Router(routes, default_route, to_msg)
}

pub fn init_effect(router: Router(route, model, msg)) {
  modem.init(fn(uri) {
    get_route_and_query(router.routes, uri)
    |> result.unwrap(#(router.default_route, []))
    |> fn(def) { #({ def.0 }.route_id, def.1) }
    |> router.to_msg
  })
}

fn get_route_and_query(routes: List(RouteDef(route, model, msg)), uri: uri.Uri) {
  use query <- result.try(uri.query |> option.unwrap("") |> uri.parse_query)
  use route <- result.try(find_route_by_uri(routes, uri))
  Ok(#(route, query))
}

fn find_route_by_uri(
  routes: List(RouteDef(route, model, msg)),
  uri: uri.Uri,
) -> Result(RouteDef(route, model, msg), Nil) {
  use route <- list.find(routes)
  test_route(route.path, uri.path |> uri.path_segments)
}

fn test_route(route_path: List(String), uri_path: List(String)) -> Bool {
  case route_path, uri_path {
    [], [] -> True
    [first, ..first_rest], [second, ..second_rest] if first == second ->
      test_route(first_rest, second_rest)
    _, _ -> False
  }
}

pub fn on_change(
  route: route,
  params: List(#(String, String)),
  router: Router(route, model, msg),
) -> effect.Effect(msg) {
  case find_route_by_route(router.routes, route) {
    Error(_) -> effect.none()
    Ok(route_def) -> route_def.on_load(params)
  }
}

fn find_route_by_route(
  routes: List(RouteDef(route, model, msg)),
  route_id: route,
) -> Result(RouteDef(route, model, msg), Nil) {
  use route <- list.find(routes)
  route.route_id == route_id
}

pub fn go_to(
  router: Router(route, model, msg),
  route: route,
  query: List(#(String, String)),
) -> effect.Effect(msg) {
  case find_route_by_route(router.routes, route) {
    Error(_) -> {
      io.println_error("Route not registered: " <> string.inspect(route))
      effect.none()
    }
    Ok(route_def) ->
      modem.push(
        "/" <> route_def.path |> string.join("/"),
        option.Some(query |> uri.query_to_string),
        option.None,
      )
  }
}

pub fn href(
  router: Router(route, model, msg),
  route: route,
  query: List(#(String, String)),
) -> attribute.Attribute(msg) {
  case find_route_by_route(router.routes, route) {
    Error(_) -> {
      io.println_error("Route not registered: " <> string.inspect(route))
      attribute.none()
    }
    Ok(route_def) ->
      attribute.href(
        "/"
        <> route_def.path |> string.join("/")
        <> "?"
        <> query |> uri.query_to_string,
      )
  }
}
