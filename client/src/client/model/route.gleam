// import gleam/option
// import gleam/uri
// import lustre/attribute
// import lustre/effect
// import modem
// import shared
import client/model/router
import convert
import shared

pub type Route {
  ErrorRoute
  HomeRoute
  QwizesRoute
  CreateQwizRoute
  QwizRoute
  CreateQuestionRoute
  QuestionRoute
  CreateAnswerRoute
  UpdateAnswerRoute
  UpdateQuestionRoute
  UpdateQwizRoute
}

pub fn home() {
  router.RouteIdentifier(HomeRoute, [], convert.null())
}

pub fn qwiz() {
  router.RouteIdentifier(QwizRoute, ["qwiz"], shared.uuid_converter())
}

pub fn qwizes() {
  router.RouteIdentifier(QwizesRoute, ["qwizes"], convert.null())
}

pub fn question() {
  router.RouteIdentifier(QuestionRoute, ["question"], shared.uuid_converter())
}

pub fn create_answer() {
  router.RouteIdentifier(
    CreateAnswerRoute,
    ["answer", "create"],
    convert.null(),
  )
}

pub fn create_question() {
  router.RouteIdentifier(
    CreateQuestionRoute,
    ["question", "create"],
    convert.null(),
  )
}

pub fn create_qwiz() {
  router.RouteIdentifier(CreateQwizRoute, ["qwiz", "create"], convert.null())
}

pub fn update_answer() {
  router.RouteIdentifier(
    UpdateAnswerRoute,
    ["answer", "update"],
    shared.uuid_converter(),
  )
}

pub fn update_question() {
  router.RouteIdentifier(
    UpdateQuestionRoute,
    ["question", "update"],
    shared.uuid_converter(),
  )
}

pub fn update_qwiz() {
  router.RouteIdentifier(
    UpdateQwizRoute,
    ["qwiz", "update"],
    shared.uuid_converter(),
  )
}
