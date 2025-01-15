import client/utils
import shared
import shared/question

pub fn get_question(question_id: shared.Uuid, cb) -> Nil {
  utils.exec_procedure(question.get_question(), question_id, cb)
}

pub fn create_question(data: question.CreateQuestion, cb) -> Nil {
  utils.exec_procedure(question.create_question(), data, cb)
}

pub fn update_question(question: question.Question, cb) -> Nil {
  utils.exec_procedure(question.update_question(), question, cb)
}

pub fn delete_question(id: shared.Uuid, cb) -> Nil {
  utils.exec_procedure(question.delete_question(), id, cb)
}
