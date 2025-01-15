import client/model/route
import client/model/router
import client/services/question_service
import client/services/qwiz_service
import gleam/option
import lustre/effect
import shared
import shared/answer
import shared/question
import shared/qwiz
import shared/user

pub type Model {
  Model(
    route: route.Route,
    params: List(#(String, String)),
    router: router.Router(route.Route, Model, Msg),
    user: option.Option(user.User),
    qwizes: List(qwiz.Qwiz),
    qwiz: option.Option(qwiz.QwizWithQuestions),
    question: option.Option(question.QuestionWithAnswers),
  )
}

pub type Msg {
  ChangeRoute(route: route.Route, query: List(#(String, String)))

  // Model Change Messages
  SetUser(user: user.User)
  SetQwizes(qwizes: List(qwiz.Qwiz))
  SetQwiz(qwiz: qwiz.QwizWithQuestions)
  SetQuestion(question: question.QuestionWithAnswers)

  UserMsg(msg: UserMsg)
  QwizMsg(msg: QwizMsg)
  QuestionMsg(msg: QuestionMsg)
  AnswerMsg(msg: AnswerMsg)
}

pub type UserMsg {
  Login(username: String, password: String)
}

pub type QwizMsg {
  CreateQwiz(data: qwiz.CreateQwiz)
  QwizCreated(qwiz: qwiz.QwizWithQuestions)
  DeleteQwiz(id: shared.Uuid)
  QwizDeleted(id: shared.Uuid)
  UpdateQwiz(new_qwiz: qwiz.Qwiz)
  QwizUpdated(qwiz: qwiz.QwizWithQuestions)
}

pub type QuestionMsg {
  CreateQuestion(data: question.CreateQuestion)
  QuestionCreated(question: question.QuestionWithAnswers)
  DeleteQuestion(id: shared.Uuid)
  QuestionDeleted(id: shared.Uuid)
  UpdateQuestion(new_question: question.Question)
  QuestionUpdated(question: question.QuestionWithAnswers)
}

pub type AnswerMsg {
  CreateAnswer(data: answer.CreateAnswer)
  AnswerCreated(answer: answer.Answer)
  DeleteAnswer(answer_id: shared.Uuid)
  AnswerDeleted(answer_id: shared.Uuid)
  UpdateAnswer(new_answer: answer.Answer)
  AnswerUpdated(answer: answer.Answer)
}
// pub fn on_load(route: route.Route) -> effect.Effect(Msg) {
//   case route {
//     route.QwizesRoute ->
//       effect.from(fn(dispatch) {
//         use qwizes <- qwiz_service.get_qwizes()
//         SetQwizes(qwizes) |> dispatch
//       })
//     route.QwizRoute(id) ->
//       effect.from(fn(dispatch) {
//         use qw <- qwiz_service.get_qwiz(id)
//         SetQwiz(qw) |> dispatch
//       })
//     route.QuestionRoute(id) ->
//       effect.from(fn(dispatch) {
//         use qu <- question_service.get_question(id)
//         SetQuestion(qu) |> dispatch
//       })
//     _ -> effect.none()
//   }
// }
