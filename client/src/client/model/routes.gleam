import client/model/model
import client/model/route
import client/model/router
import client/services/question_service
import client/views/home
import client/views/question as question_view
import convert
import lustre/effect
import shared

pub fn home() -> router.RouteDef(route.Route, model.Model, model.Msg, Nil) {
  router.RouteDef(
    route_id: route.HomeRoute,
    path: [],
    param_converter: convert.null(),
    on_load: fn(_model, _param) { effect.none() },
    view_fn: home.view,
  )
}

pub fn question() -> router.RouteDef(
  route.Route,
  model.Model,
  model.Msg,
  shared.Uuid,
) {
  router.RouteDef(
    route_id: route.QuestionRoute,
    path: ["question"],
    param_converter: shared.uuid_converter(),
    on_load: fn(model: model.Model, id: shared.Uuid) {
      effect.from(fn(dispatch) {
        use qu <- question_service.get_question(id)
        model.SetQuestion(qu) |> dispatch
      })
    },
    view_fn: question.view,
  )
}
