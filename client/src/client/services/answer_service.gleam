import client/utils
import shared
import shared/answer

pub fn create_answer(data: answer.CreateAnswer, cb) {
  utils.exec_procedure(answer.create_answer(), data, cb)
}

pub fn update_answer(answer: answer.Answer, cb) {
  utils.exec_procedure(answer.update_answer(), answer, cb)
}

pub fn delete_answer(id: shared.Uuid, cb) {
  utils.exec_procedure(answer.delete_answer(), id, cb)
}
