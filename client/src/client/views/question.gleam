import client/handlers/answer_handler
import client/handlers/question_handler
import client/model/model
import client/model/route
import client/model/router
import client/services/question_service
import client/views/common
import gleam/list
import gleam/option
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import shared
import shared/answer

pub fn on_load(model: model.Model, id: shared.Uuid) {
  use dispatch <- effect.from
  use qu <- question_service.get_question(id)
  model.SetQuestion(qu) |> dispatch
}

pub fn view(model: model.Model, _param) -> element.Element(model.Msg) {
  case model.question {
    option.None -> common.loading()
    option.Some(question) -> {
      html.div([], [
        html.div([], [
          back_button(model),
          html.h1([], [html.text(question.question)]),
          edit_question_button(question.id),
          delete_question_button(question.id),
        ]),
        answer_list(question.answers),
        create_answer_button(),
      ])
    }
  }
}

fn back_button(model: model.Model) -> element.Element(model.Msg) {
  let link_data = case model.qwiz {
    option.None -> #(router.href(route.qwizes(), Nil), "Back to qwizes")
    option.Some(qw) -> #(
      router.href(route.qwiz(), qw.id),
      "Back to " <> qw.name,
    )
  }

  html.a([link_data.0], [html.text(link_data.1)])
}

fn answer_list(answers: List(answer.Answer)) -> element.Element(model.Msg) {
  element.keyed(html.div([], _), {
    use a <- list.map(answers)
    #(a.id.data, answer_row(a))
  })
}

fn answer_row(answer: answer.Answer) -> element.Element(model.Msg) {
  html.div([], [
    html.text(answer.answer),
    edit_answer_button(answer.id),
    delete_answer_button(answer.id),
  ])
}

fn edit_answer_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.a([router.href(route.update_answer(), id)], [html.text("Edit")])
}

fn delete_answer_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.button([event.on_click(answer_handler.delete(id))], [html.text("Remove")])
}

fn edit_question_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.a([router.href(route.update_question(), id)], [html.text("Edit")])
}

fn delete_question_button(id: shared.Uuid) -> element.Element(model.Msg) {
  html.button([event.on_click(question_handler.delete(id))], [
    html.text("Delete"),
  ])
}

fn create_answer_button() -> element.Element(model.Msg) {
  html.a([router.href(route.create_answer(), Nil)], [html.text("Add answer")])
}
