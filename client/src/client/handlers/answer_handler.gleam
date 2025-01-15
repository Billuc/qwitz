import client/model/model
import client/model/route
import client/services/answer_service
import gleam/list
import gleam/option
import lustre/effect
import shared
import shared/answer
import shared/question

pub fn handle_message(
  model: model.Model,
  msg: model.AnswerMsg,
) -> #(model.Model, effect.Effect(model.Msg)) {
  case msg {
    model.CreateAnswer(data) -> #(
      model,
      effect.from(fn(dispatch) {
        use a <- answer_service.create_answer(data)
        model.AnswerCreated(a) |> model.AnswerMsg |> dispatch
      }),
    )
    model.UpdateAnswer(data) -> #(
      model,
      effect.from(fn(dispatch) {
        use a <- answer_service.update_answer(data)
        model.AnswerUpdated(a) |> model.AnswerMsg |> dispatch
      }),
    )
    model.DeleteAnswer(id) -> #(
      model,
      effect.from(fn(dispatch) {
        use _ <- answer_service.delete_answer(id)
        model.AnswerDeleted(id) |> model.AnswerMsg |> dispatch
      }),
    )

    model.AnswerCreated(answer) -> #(
      model,
      route.go_to(route.QuestionRoute(answer.question_id)),
    )
    model.AnswerUpdated(a) -> #(
      model,
      route.go_to(route.QuestionRoute(a.question_id)),
    )
    model.AnswerDeleted(id) -> #(model |> remove_answer(id), effect.none())
  }
}

fn remove_answer(model: model.Model, id: shared.Uuid) -> model.Model {
  model.Model(
    ..model,
    question: model.question
      |> option.map(fn(q) {
        question.QuestionWithAnswers(
          ..q,
          answers: q.answers
            |> list.filter(fn(a) { a.id != id }),
        )
      }),
  )
}

pub fn create(
  question_id: shared.Uuid,
  answer: String,
  correct: Bool,
) -> model.Msg {
  answer.CreateAnswer(question_id, answer, correct)
  |> model.CreateAnswer
  |> model.AnswerMsg
}

pub fn update(answer: answer.Answer) -> model.Msg {
  answer |> model.UpdateAnswer |> model.AnswerMsg
}

pub fn delete(id: shared.Uuid) -> model.Msg {
  id |> model.DeleteAnswer |> model.AnswerMsg
}
