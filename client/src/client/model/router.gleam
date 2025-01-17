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
pub type RouteIdentifier(route, param) {
  RouteIdentifier(
    route_id: route,
    path: List(String),
    param_converter: convert.Converter(param),
  )
}

type RouteInRouter(route, model, msg) {
  RouteInRouter(
    route_id: route,
    path: List(String),
    on_load: fn(model, List(#(String, String))) -> effect.Effect(msg),
    view_fn: fn(model, List(#(String, String))) -> element.Element(msg),
  )
}

pub type ErrorPageFn(route, msg) =
  fn(option.Option(route), List(String), List(#(String, String))) ->
    element.Element(msg)

pub opaque type Router(route, model, msg) {
  Router(
    routes: List(RouteInRouter(route, model, msg)),
    to_msg: fn(#(route, List(#(String, String)))) -> msg,
    error_page: ErrorPageFn(route, msg),
    error_route: route,
  )
}

pub fn init(
  to_msg: fn(#(route, List(#(String, String)))) -> msg,
  error_page: ErrorPageFn(route, msg),
  error_route: route,
) {
  Router(routes: [], to_msg:, error_page:, error_route:)
}

pub fn register(
  router: Router(route, model, msg),
  route: RouteIdentifier(route, param),
  on_load: fn(model, param) -> effect.Effect(msg),
  view_fn: fn(model, param) -> element.Element(msg),
) {
  let new_route =
    route_data_to_router_route(route, on_load, view_fn, router.error_page)
  Router(..router, routes: [new_route, ..router.routes])
}

pub fn std_error_page() -> ErrorPageFn(route, msg) {
  fn(
    route_id: option.Option(route),
    path: List(String),
    query: List(#(String, String)),
  ) {
    html.div([], [
      html.h1([], [html.text("An error happened with this page")]),
      html.br([]),
      case route_id {
        option.None ->
          html.p([], [
            html.text("No route found at path /"),
            html.text(path |> string.join("/")),
          ])
        option.Some(route_id) ->
          html.p([], [
            html.text("Route found: "),
            html.text(string.inspect(route_id)),
          ])
      },
      html.br([]),
      html.p([], [
        html.text("Query provided: "),
        html.text(uri.query_to_string(query)),
      ]),
    ])
  }
}

fn route_data_to_router_route(
  identifier: RouteIdentifier(route, param),
  on_load: fn(model, param) -> effect.Effect(msg),
  view_fn: fn(model, param) -> element.Element(msg),
  error_page: ErrorPageFn(route, msg),
) -> RouteInRouter(route, model, msg) {
  RouteInRouter(
    route_id: identifier.route_id,
    path: identifier.path,
    on_load: fn(model: model, query: List(#(String, String))) {
      let param = query |> query.decode(identifier.param_converter)

      case param {
        Error(_) ->
          effect.from(fn(_) {
            io.println_error(
              "Wrong query for route "
              <> string.inspect(identifier.route_id)
              <> " : "
              <> uri.query_to_string(query),
            )
          })
        Ok(param) -> on_load(model, param)
      }
    },
    view_fn: fn(model: model, query: List(#(String, String))) {
      let param = query |> query.decode(identifier.param_converter)

      case param {
        Error(_) ->
          error_page(option.Some(identifier.route_id), identifier.path, query)
        Ok(param) -> view_fn(model, param)
      }
    },
  )
}

pub fn init_effect(router: Router(route, model, msg)) -> effect.Effect(msg) {
  modem.init(fn(uri) {
    let query = get_query_from_uri(uri) |> result.unwrap([])
    let route_id =
      find_route_by_uri(router.routes, uri)
      |> result.map(fn(route) { route.route_id })
      |> result.unwrap(router.error_route)

    router.to_msg(#(route_id, query))
  })
}

fn get_query_from_uri(uri: uri.Uri) -> Result(List(#(String, String)), Nil) {
  uri.query |> option.unwrap("") |> uri.parse_query
}

fn find_route_by_uri(
  routes: List(RouteInRouter(route, model, msg)),
  uri: uri.Uri,
) -> Result(RouteInRouter(route, model, msg), Nil) {
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
  route.route_id == route_id
}

pub fn go_to(
  route: RouteIdentifier(route, param),
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
  route: RouteIdentifier(route, param),
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
  |> result.map(fn(route_def) { route_def.view_fn(model, query) })
  |> result.unwrap(router.error_page(option.Some(route), [], query))
}

pub fn initial_route(
  router: Router(route, model, msg),
) -> Result(#(route, List(String), List(#(String, String))), Nil) {
  use uri <- result.try(modem.initial_uri())
  use query <- result.try(get_query_from_uri(uri))
  use route <- result.try(find_route_by_uri(router.routes, uri))

  Ok(#(route.route_id, route.path, query))
}

pub fn no_load(_model, _param) -> effect.Effect(msg) {
  effect.none()
}
