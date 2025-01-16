import convert
import convert/http/query
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/uri
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import modem

// This is experimental
pub type RouteIdentifier(route) {
  RouteIdentifier(route_id: route, path: List(String))
}

pub type RouteDef(route, model, msg, param) {
  RouteDef(
    route_id: route,
    path: List(String),
    param_converter: convert.Converter(param),
    on_load: fn(model, param) -> effect.Effect(msg),
    view_fn: fn(model, param) -> element.Element(msg),
  )
}

type RouteInRouter(route, model, msg) {
  RouteInRouter(
    identifier: RouteIdentifier(route),
    on_load: fn(model, List(#(String, String))) -> effect.Effect(msg),
    view_fn: fn(model, List(#(String, String))) -> element.Element(msg),
  )
}

pub opaque type Router(route, model, msg) {
  Router(
    routes: List(RouteInRouter(route, model, msg)),
    default_route: RouteInRouter(route, model, msg),
    to_msg: fn(#(route, List(#(String, String)))) -> msg,
    error_page: fn(RouteIdentifier(route), List(#(String, String))) ->
      element.Element(msg),
  )
}

pub fn init(
  default_route: RouteDef(route, model, msg, param),
  to_msg: fn(#(route, List(#(String, String)))) -> msg,
  error_page: fn(RouteIdentifier(route), List(#(String, String))) ->
    element.Element(msg),
) {
  let default = route_def_to_router_route(default_route, error_page)
  Router([default], default, to_msg, error_page)
}

pub fn add_route(
  router: Router(route, model, msg),
  route: RouteDef(route, model, msg, param),
) {
  let new_route = route_def_to_router_route(route, router.error_page)
  Router(..router, routes: [new_route, ..router.routes])
}

pub fn std_error_page(
  identifier: RouteIdentifier(route),
  query: List(#(String, String)),
) -> element.Element(msg) {
  html.div([], [
    html.h1([], [html.text("An error happened with this page")]),
    html.br([]),
    html.p([], [
      html.text("Route found: "),
      html.text(string.inspect(identifier.route_id)),
    ]),
    html.br([]),
    html.p([], [
      html.text("Query provided: "),
      html.text(uri.query_to_string(query)),
    ]),
  ])
}

fn route_def_to_router_route(
  route_def: RouteDef(route, model, msg, param),
  error_page: fn(RouteIdentifier(route), List(#(String, String))) ->
    element.Element(msg),
) -> RouteInRouter(route, model, msg) {
  let identifier = RouteIdentifier(route_def.route_id, route_def.path)

  RouteInRouter(
    identifier: identifier,
    on_load: fn(model: model, query: List(#(String, String))) {
      let param = query |> query.decode(route_def.param_converter)

      case param {
        Error(_) ->
          effect.from(fn(_) {
            io.println_error(
              "Wrong query for route "
              <> string.inspect(route_def.route_id)
              <> " : "
              <> uri.query_to_string(query),
            )
          })
        Ok(param) -> route_def.on_load(model, param)
      }
    },
    view_fn: fn(model: model, query: List(#(String, String))) {
      let param = query |> query.decode(route_def.param_converter)

      case param {
        Error(_) -> error_page(identifier, query)
        Ok(param) -> route_def.view_fn(model, param)
      }
    },
  )
}

pub fn init_effect(router: Router(route, model, msg)) {
  modem.init(fn(uri) {
    get_route_and_query(router.routes, uri)
    |> result.unwrap(#(router.default_route, []))
    |> fn(def) { #({ def.0 }.identifier.route_id, def.1) }
    |> router.to_msg
  })
}

fn get_route_and_query(
  routes: List(RouteInRouter(route, model, msg)),
  uri: uri.Uri,
) {
  use query <- result.try(uri.query |> option.unwrap("") |> uri.parse_query)
  use route <- result.try(find_route_by_uri(routes, uri))
  Ok(#(route, query))
}

fn find_route_by_uri(
  routes: List(RouteInRouter(route, model, msg)),
  uri: uri.Uri,
) -> Result(RouteInRouter(route, model, msg), Nil) {
  use route <- list.find(routes)
  test_route(route.identifier.path, uri.path |> uri.path_segments)
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
  router: Router(route, model, msg),
  route: route,
  params: List(#(String, String)),
  model: model,
) -> effect.Effect(msg) {
  case find_route_by_route(router.routes, route) {
    Error(_) -> effect.none()
    Ok(route_def) -> route_def.on_load(model, params)
  }
}

fn find_route_by_route(
  routes: List(RouteInRouter(route, model, msg)),
  route_id: route,
) -> Result(RouteInRouter(route, model, msg), Nil) {
  use route <- list.find(routes)
  route.identifier.route_id == route_id
}

pub fn go_to(
  route: RouteDef(route, model, msg, param),
  param: param,
) -> effect.Effect(msg) {
  let path = "/" <> route.path |> string.join("/")
  let query =
    param
    |> query.encode(route.param_converter)
    |> uri.query_to_string

  modem.push(path, option.Some(query), option.None)
}

pub fn href(
  route: RouteDef(route, model, msg, param),
  param: param,
) -> attribute.Attribute(msg) {
  let path = "/" <> route.path |> string.join("/")
  let query =
    param
    |> query.encode(route.param_converter)
    |> uri.query_to_string

  attribute.href(path <> "?" <> query)
}

pub fn view(
  router: Router(route, model, msg),
  route: route,
  model: model,
  query: List(#(String, String)),
) -> element.Element(msg) {
  find_route_by_route(router.routes, route)
  |> result.unwrap(router.default_route)
  |> fn(route_def) { route_def.view_fn(model, query) }
}

pub fn initial_route(
  router: Router(route, model, msg),
) -> Result(#(RouteIdentifier(route), List(#(String, String))), Nil) {
  use uri <- result.try(modem.initial_uri())
  router.routes
  |> get_route_and_query(uri)
  |> result.map(fn(data) { #({ data.0 }.identifier, data.1) })
}
