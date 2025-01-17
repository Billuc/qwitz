import convert
import convert/http/query
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/uri
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import modem
import plinth/browser/window

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
  query: List(#(String, String)),
  model: model,
) -> effect.Effect(msg) {
  case find_route_by_route(router.routes, route) {
    Error(_) -> effect.none()
    Ok(route_def) -> route_def.on_load(model, query)
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
) -> fn(model) -> element.Element(msg) {
  fn(model: model) {
    case window.location() |> uri.parse {
      Error(_) -> router.error_page(option.None, [], [])
      Ok(uri) -> {
        case get_query_from_uri(uri) {
          Error(_) -> router.error_page(option.None, [], [])
          Ok(query) -> {
            find_route_by_uri(router.routes, uri)
            |> result.map(fn(route_def) { route_def.view_fn(model, query) })
            |> result.unwrap(router.error_page(option.None, [], query))
          }
        }
      }
    }
  }
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

pub fn application(
  init: fn(flags) -> #(model, effect.Effect(msg)),
  update: fn(model, msg) -> #(model, effect.Effect(msg)),
  router: Router(route, model, msg),
) {
  lustre.application(
    router_init(init, router),
    router_update(update, router),
    router_view(router),
  )
}

pub type RouterModel(model) {
  RouterModel(model: model)
}

pub type RouterMsg(route, msg) {
  RouterErrorMsg
  OnRouteChange(route: route, query: List(#(String, String)))
  UserMsg(msg: msg)
}

pub type RouterRoute(route) {
  ErrorRoute
  UserRoute(route: route)
}

pub fn router_init(
  init: fn(flags) -> #(model, effect.Effect(msg)),
  router: Router(route, model, msg),
) -> fn(flags) -> #(RouterModel(model), effect.Effect(RouterMsg(route, msg))) {
  fn(flags: flags) {
    let init_result = init(flags)

    #(
      RouterModel(init_result.0),
      effect.batch(
        [init_effect(router), init_result.1]
        |> list.map(fn(eff_msg) { effect.map(eff_msg, UserMsg) }),
      ),
    )
  }
}

pub fn router_update(
  update: fn(model, msg) -> #(model, effect.Effect(msg)),
  router: Router(route, model, msg),
) -> fn(RouterModel(model), RouterMsg(route, msg)) ->
  #(RouterModel(model), effect.Effect(RouterMsg(route, msg))) {
  fn(model: RouterModel(model), msg: RouterMsg(route, msg)) {
    case msg {
      UserMsg(msg) -> {
        let update_result = update(model.model, msg)
        #(RouterModel(update_result.0), effect.map(update_result.1, UserMsg))
      }
      OnRouteChange(route, query) -> #(
        model,
        router |> on_change(route, query, model.model) |> effect.map(UserMsg),
      )
    }
  }
}

pub fn router_view(
  router: Router(route, model, msg),
) -> fn(RouterModel(model)) -> element.Element(RouterMsg(route, msg)) {
  fn(model: RouterModel(model)) {
    view(router)(model.model) |> element.map(UserMsg)
  }
}

pub fn app_init(error_page: ErrorPageFn(route, msg)) {
  Router(
    routes: [],
    to_msg: fn(data: #(RouterRoute(route), List(#(String, String)))) -> RouterMsg(
      route,
      msg,
    ) {
      case data.0 {
        ErrorRoute -> todo
        UserRoute(route) -> OnRouteChange(route, data.1)
      }
    },
    error_page: fn(
      route: option.Option(RouterRoute(route)),
      path: List(String),
      query: List(#(String, String)),
    ) -> element.Element(RouterMsg(route, msg)) {
      let route_opt = case route {
        option.None | option.Some(ErrorRoute) -> option.None
        option.Some(UserRoute(route)) -> option.Some(route)
      }

      error_page(route_opt, path, query) |> element.map(UserMsg)
    },
    error_route: ErrorRoute,
  )
}
