import gleam/option
import shared
import shared/answer
import shared/question
import shared/qwiz
import shared/user

pub type Model {
  Model(
    user: option.Option(user.User),
    qwizes: List(qwiz.Qwiz),
    qwiz: option.Option(qwiz.QwizWithQuestions),
    question: option.Option(question.QuestionWithAnswers),
  )
}

pub type Msg {
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

pub type Route {
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
