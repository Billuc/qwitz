import client/model/model
import client/model/route
import client/model/router
import client/services/qwiz_service
import lustre/effect
import shared
import shared/qwiz

pub fn handle_message(
  model: model.Model,
  msg: model.QwizMsg,
) -> #(model.Model, effect.Effect(model.Msg)) {
  case msg {
    model.CreateQwiz(data) -> #(
      model,
      effect.from(fn(dispatch) {
        use new_qwiz <- qwiz_service.create_qwiz(data)
        model.QwizCreated(new_qwiz) |> model.QwizMsg |> dispatch
      }),
    )
    model.UpdateQwiz(data) -> #(
      model,
      effect.from(fn(dispatch) {
        use qw <- qwiz_service.update_qwiz(data)
        model.QwizUpdated(qw) |> model.QwizMsg |> dispatch
      }),
    )
    model.DeleteQwiz(id) -> #(
      model,
      effect.from(fn(dispatch) {
        use _ <- qwiz_service.delete_qwiz(id)
        model.QwizDeleted(id) |> model.QwizMsg |> dispatch
      }),
    )

    model.QwizCreated(qwiz) -> #(model, router.go_to(route.qwiz(), qwiz.id))
    model.QwizUpdated(qwiz) -> #(model, router.go_to(route.qwiz(), qwiz.id))
    model.QwizDeleted(_) -> #(model, router.go_to(route.qwizes(), Nil))
  }
}

pub fn create(name: String, owner: shared.Uuid) -> model.Msg {
  qwiz.CreateQwiz(name:, owner:)
  |> model.CreateQwiz
  |> model.QwizMsg
}

pub fn update(data: qwiz.Qwiz) -> model.Msg {
  data |> model.UpdateQwiz |> model.QwizMsg
}

pub fn delete(id: shared.Uuid) -> model.Msg {
  id |> model.DeleteQwiz |> model.QwizMsg
}
