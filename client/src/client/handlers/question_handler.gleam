import client/model/model
import client/model/route
import client/model/router
import client/services/question_service
import gleam/option
import lustre/effect
import shared
import shared/question

pub fn handle_message(
  model: model.Model,
  msg: model.QuestionMsg,
) -> #(model.Model, effect.Effect(model.Msg)) {
  case msg {
    model.CreateQuestion(data) -> #(
      model,
      effect.from(fn(dispatch) {
        use question <- question_service.create_question(data)
        model.QuestionCreated(question) |> model.QuestionMsg |> dispatch
      }),
    )
    model.UpdateQuestion(q) -> #(
      model,
      effect.from(fn(dispatch) {
        use q <- question_service.update_question(q)
        model.QuestionUpdated(q) |> model.QuestionMsg |> dispatch
      }),
    )
    model.DeleteQuestion(id) -> #(
      model,
      effect.from(fn(dispatch) {
        use _ <- question_service.delete_question(id)
        model.QuestionDeleted(id) |> model.QuestionMsg |> dispatch
      }),
    )

    model.QuestionCreated(question) -> #(
      model,
      model.router
        |> router.go_to(route.QuestionRoute, [#("id", question.id.data)]),
    )
    model.QuestionUpdated(q) -> #(
      model,
      model.router |> router.go_to(route.QuestionRoute, [#("id", q.id.data)]),
    )
    model.QuestionDeleted(_) -> #(model, case model.qwiz {
      option.None -> model.router |> router.go_to(route.QwizesRoute, [])
      option.Some(qwiz) ->
        model.router |> router.go_to(route.QwizRoute, [#("id", qwiz.id.data)])
    })
  }
}

pub fn create(qwiz_id: shared.Uuid, question: String) -> model.Msg {
  question.CreateQuestion(qwiz_id:, question:)
  |> model.CreateQuestion
  |> model.QuestionMsg
}

pub fn update(data: question.Question) -> model.Msg {
  data |> model.UpdateQuestion |> model.QuestionMsg
}

pub fn delete(id: shared.Uuid) -> model.Msg {
  id |> model.DeleteQuestion |> model.QuestionMsg
}
