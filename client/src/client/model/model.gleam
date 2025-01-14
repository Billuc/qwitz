import client/model/model_msg
import client/model/route
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
    user: option.Option(user.User),
    qwizes: List(qwiz.Qwiz),
    qwiz: option.Option(qwiz.QwizWithQuestions),
    question: option.Option(question.QuestionWithAnswers),
  )
}

pub type Msg {
  Login(username: String, password: String)
  SetUser(user: user.User)
  ChangeRoute(route: route.Route)

  // Model Change Messages
  SetQwizes(qwizes: List(qwiz.Qwiz))
  SetQwiz(qwiz: qwiz.QwizWithQuestions)
  SetQuestion(question: question.QuestionWithAnswers)

  // Qwiz Messages
  CreateQwiz(name: String, owner: shared.Uuid)
  QwizCreated(qwiz: qwiz.QwizWithQuestions)
  DeleteQwiz(id: shared.Uuid)
  QwizDeleted(id: shared.Uuid)
  UpdateQwiz(new_qwiz: qwiz.Qwiz)
  QwizUpdated(qwiz: qwiz.QwizWithQuestions)

  // Question Messages
  CreateQuestion(qwiz_id: shared.Uuid, question: String)
  QuestionCreated(question: question.QuestionWithAnswers)
  DeleteQuestion(id: shared.Uuid)
  QuestionDeleted(id: shared.Uuid)
  UpdateQuestion(new_question: question.Question)
  QuestionUpdated(question: question.QuestionWithAnswers)

  // Answer Messages
  CreateAnswer(question_id: shared.Uuid, answer: String, correct: Bool)
  AnswerCreated(answer: answer.Answer)
  DeleteAnswer(answer_id: shared.Uuid)
  AnswerDeleted(answer_id: shared.Uuid)
  UpdateAnswer(new_answer: answer.Answer)
  AnswerUpdated(answer: answer.Answer)
}

pub fn on_load(route: route.Route) -> effect.Effect(model_msg.ModelMsg) {
  case route {
    route.QwizesRoute -> {
      use qwizes <- qwiz_service.get_qwizes()
      model_msg.SetQwizes(qwizes)
    }
    route.QwizRoute(id) -> {
      use qw <- qwiz_service.get_qwiz(id)
      model_msg.SetQwiz(qw)
    }
    route.QuestionRoute(id) -> {
      use qu <- question_service.get_question(id)
      model_msg.SetQuestion(qu)
    }
    _ -> effect.none()
  }
}
