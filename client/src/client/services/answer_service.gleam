import client/utils
import lustre/effect
import shared
import shared/answer

pub fn create_answer(
  question_id: shared.Uuid,
  answer: String,
  correct: Bool,
  cb,
) -> effect.Effect(c) {
  utils.rpc_effect(
    answer.create_answer(),
    answer.CreateAnswer(question_id:, answer:, correct:),
    cb,
  )
}

pub fn delete_question(id: shared.Uuid, cb: fn(Nil) -> d) -> effect.Effect(d) {
  utils.rpc_effect(answer.delete_answer(), id, cb)
}
